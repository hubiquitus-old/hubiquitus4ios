/*
 * Copyright (c) Novedia Group 2012.
 *
 *     This file is part of Hubiquitus.
 *
 *     Hubiquitus is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Hubiquitus is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with Hubiquitus.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "HClient.h"
#import "DDLog.h"
#import "HMessage.h"
#import "HCommand.h"
#import "HConvState.h"
#import "HAck.h"
#import "hMeasure.h"
#import "HAlert.h"
#import "HResult.h"
#import "ErrorCode.h"
#import "HNativeObjectsCategories.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const NSString * hNodeName = @"hnode";
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface HClient () {
    dispatch_queue_t _notificationsQueue; /** queue used to sequentially notify client of a status or a message */
}
@property (nonatomic, strong) HTransport * transport;
@property (nonatomic, strong) NSMutableDictionary * callbacks;
@property (nonatomic, readonly) NSString * hnodeJid;

@end



/**
 * @version 0.5.0
 * Hubiquitus API for ios
 * Hubiquitus is an attempt to provide a simple way to develop networks of smart agents - say actors - that can interact together with connected things - say objects, sensors, user devices - and humans.
 */

@implementation HClient
@synthesize onStatus, onMessage;
@synthesize callbacks;
@synthesize transport;

- (id)init {
    self = [super init];
    if(self) {
        _notificationsQueue = dispatch_queue_create("HClient.notifications.queue", NULL);
        self.transport = [[HTransport alloc] initWith:self];
        self.callbacks = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    dispatch_release(_notificationsQueue);
}

- (NSString *)hnodeJid {
    return [NSString stringWithFormat:@"%@@%@", hNodeName, self.transport.options.jidDomain];
}

/**
 * Called to connect to hNode
 * This will only be called if disconnect. If not, it will return a hStatus with error code ALREADY_CONNECTED
 */
- (void)connectWithPublisher:(NSString *)publisher password:(NSString *)password options:(HOptions *)options {
    if (!options)
        options = [[HOptions alloc] init];
    
    HTransportOptions * transportOpts = [[HTransportOptions alloc] initWithOptions:options];
    transportOpts.jid = publisher;
    transportOpts.password = password;
    [self.transport connectWithOptions:transportOpts];
}

/**
 * disconnect from the hNode
 */
- (void)disconnect {
    [self.transport disconnect];
}

- (Status)status {
    return self.transport.status;
}

- (void)send:(HMessage *)message withBlock:(void (^)(HMessage *))callback {
    DDLogVerbose(@"trying to send message %@ through hAPI", message);
    if(!message) {
        [self errorNotification:RES_MISSING_ATTR errorMsg:@"Nil message" refMsg:@"-1" timeout:0 withBlock:callback];
        return;
    }
    
    if(!message.actor || message.actor.length <= 0) {
        [self errorNotification:RES_MISSING_ATTR errorMsg:@"Missing actor" refMsg:@"-1" timeout:message.timeout withBlock:callback];
        return;
    }
    
    message.sent = [NSDate date];
    message.msgid = @""; //msgid is set only if there is a timeout
    message.publisher = self.transport.options.jid;
    
    if(callback == nil || message.timeout < 0) {
        message.timeout = 0;
    }
    
    if(callback != nil && message.timeout > 0) {
        message.msgid = [self uuid];
        [self.callbacks setObject:callback forKey:message.msgid];
        //add a timeout handler
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (message.timeout * NSEC_PER_MSEC)), _notificationsQueue, ^() {
            
            if([callbacks objectForKey:message.msgid]) {
                [callbacks removeObjectForKey:message.msgid];
                
                HMessage * timeoutResponse = [self buildResultWithActor:self.transport.options.jid ref:message.msgid status:RES_EXEC_TIMEOUT result:nil options:nil didFailWithError:nil];
                
                callback(timeoutResponse);
            }
        });
    }
    
    @try {
        [self.transport send:message];
    } @catch(NSException * e) {
        DDLogError(@"Unhandled Exception happened while trying to send a message : %@", e);
    }
    
   
}

#pragma mark - standard functions
- (void)getSubscriptionsWithBlock:(void (^)(HMessage *))callback {
    if (callback == nil) {
        return;
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.timeout;
    
    HMessage *cmd = [self buildCommandWithActor:self.hnodeJid cmd:@"hgetsubscriptions" params:nil options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

- (void)subscribeToActor:(NSString *)actor withBlock:(void (^)(HMessage *))callback {
    if (callback == nil) {
        return;
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.timeout;
    
    HMessage *cmd = [self buildCommandWithActor:actor cmd:@"hsubscribe" params:nil options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

- (void)getLastMessagesFromActor:(NSString *)actor quantity:(NSNumber *)quantity withBlock:(void (^)(HMessage *))callback {
    
    if (callback == nil) {
        return;
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.timeout;

    NSDictionary * params = nil;
    
    if(quantity != nil)
        params = [NSDictionary dictionaryWithObject:quantity forKey:@"nbLastMsg"];
    
    HMessage *cmd = [self buildCommandWithActor:self.hnodeJid cmd:@"hgetlastmessages" params:params options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

- (void)getThreadFromActor:(NSString *)actor withConvid:(NSString *)convid block:(void (^)(HMessage *))callback {
    
    if (callback == nil) {
        return;
    }
    
    if(!convid || convid.length <= 0) {
        [self errorNotification:RES_MISSING_ATTR errorMsg:@"Missing convid" refMsg:@"-1" timeout:self.transport.options.timeout withBlock:callback];
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.timeout;
    
    NSDictionary * params = [NSDictionary dictionaryWithObject:convid forKey:@"convid"];
    
    HMessage *cmd = [self buildCommandWithActor:self.hnodeJid cmd:@"hgetthread" params:params options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

- (void)getThreadsFromActor:(NSString *)actor withStatus:(NSString *)status block:(void (^)(HMessage *))callback {
    
    if (callback == nil) {
        return;
    }
    
    if(!status || status.length <= 0) {
        [self errorNotification:RES_MISSING_ATTR errorMsg:@"Missing status" refMsg:@"-1" timeout:self.transport.options.timeout withBlock:callback];
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.timeout;
    
    NSDictionary * params = [NSDictionary dictionaryWithObject:status forKey:@"status"];
    
    HMessage *cmd = [self buildCommandWithActor:self.hnodeJid cmd:@"hgetthreads" params:params options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

- (void)getRelevantMessagesFromActor:(NSString *)actor withBlock:(void (^)(HMessage *))callback {
    
    if (callback == nil) {
        return;
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.timeout;
    
    HMessage *cmd = [self buildCommandWithActor:self.hnodeJid cmd:@"hrelevantmessages" params:nil options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

- (void)unscribeFromActor:(NSString *)actor withBlock:(void (^)(HMessage *))callback {
    
    if (callback == nil) {
        return;
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.timeout;
    
    HMessage *cmd = [self buildCommandWithActor:self.hnodeJid cmd:@"hunsubscribe" params:nil options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

#pragma mark - builders
- (HMessage *)buildMessageWithActor:(NSString *)actor type:(NSString *)type payload:(id<HObj>)payload options:(HMessageOptions *)msgOptions didFailWithError:(NSError **)error {
    HMessage * msg = nil;
    
    if(actor == nil || [actor length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"actor", @"attr", nil]];
        return nil;
    }
    
    msg = [[HMessage alloc] init];
    msg.actor = actor;
    msg.type = type;
    msg.payload = payload;
    
    if(self.transport.options)
        msg.publisher = self.transport.options.jid;
    
    if(msgOptions) {
        if(msgOptions.ref.length > 0) msg.ref = msgOptions.ref;
        if(msgOptions.convid.length > 0) msg.convid = msgOptions.convid;
        if(msgOptions.priority >= 0) msg.priority = msgOptions.priority;
        if(msgOptions.relevance != nil) msg.relevance = msgOptions.relevance;
        if(msgOptions.persistent) msg.persistent = msgOptions.persistent;
        if(msgOptions.location != nil) msg.location = msgOptions.location;
        if(msgOptions.author.length > 0) msg.author = msgOptions.author;
        if(msgOptions.published != nil) msg.published = msgOptions.published;
        if(msgOptions.headers != nil) msg.headers = msgOptions.headers;
        if(msgOptions.timeout > 0) msg.timeout = msgOptions.timeout;
        
        if(msgOptions.relevanceOffset >= 0) {
            NSDate * relevance = [NSDate dateWithTimeIntervalSinceNow:(msgOptions.relevanceOffset/1000)];
            msg.relevance = relevance;
        }
    }
    
    return msg;
}

- (HMessage *)buildCommandWithActor:(NSString *)actor cmd:(NSString *)cmd params:(NSDictionary *)params options:(HMessageOptions *)msgOptions didFailWithError:(NSError **)error {
    
    if(cmd == nil || [cmd length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing cmd", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    HCommand * hCommmand = [[HCommand alloc] init];
    hCommmand.cmd = cmd;
    hCommmand.params = params;
    
    HMessage *msg = [self buildMessageWithActor:actor type:@"hCommand" payload:hCommmand options:msgOptions didFailWithError:error];
    
    return msg;
}

- (HMessage *)buildResultWithActor:(NSString *)actor ref:(NSString *)ref status:(ResultStatus)status result:(id<HObj>)result options:(HMessageOptions *)msgOptions didFailWithError:(NSError **)error {
    
    if(status < 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing status", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    if(ref == nil || [ref length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing ref", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    HResult * hResult = [[HResult alloc] init];
    hResult.status = status;
    hResult.result = result;
    
    HMessage * msg = [self buildMessageWithActor:actor type:@"hResult" payload:hResult options:msgOptions didFailWithError:error];
    
    return msg;
}

- (HMessage *)buildAlertWithActor:(NSString *)actor alert:(NSString *)alert options:(HMessageOptions *)msgOptions didFailWithError:(NSError *__autoreleasing *)error {
    
    if(alert == nil || [alert length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing alert", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    HAlert * hAlert = [[HAlert alloc] init];
    hAlert.alert = alert;
    
    HMessage * msg = [self buildMessageWithActor:actor type:@"hAlert" payload:hAlert options:msgOptions didFailWithError:error];
    
    return msg;
}

- (HMessage *)buildConvStateWithActor:(NSString *)actor convid:(NSString *)convid status:(NSString *)status option:(HMessageOptions *)msgOptions didFailWithError:(NSError *__autoreleasing *)error {
    
    if(convid == nil || [convid length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing convid", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    if(status == nil || [status length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing status", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    HConvState * hConvState = [[HConvState alloc] init];
    hConvState.status = status;
    
    if(msgOptions == nil)
        msgOptions = [[HMessageOptions alloc] init];
    
    msgOptions.convid = convid;
    
    HMessage * msg = [self buildMessageWithActor:actor type:@"hConvState" payload:hConvState options:msgOptions didFailWithError:error];
    
    return msg;
}

- (HMessage *)buildAckWithActor:(NSString *)actor ref:(NSString *)ref ack:(NSString *)ack options:(HMessageOptions *)msgOptions didFailWithError:(NSError *__autoreleasing *)error {
    
    if(ref == nil || [ref length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing ref", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    if(ack == nil || [ack length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing ack", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    HAck * hAck = [[HAck alloc] init];
    hAck.ack = ack;
    
    if(msgOptions == nil)
        msgOptions = [[HMessageOptions alloc] init];
    
    msgOptions.ref = ref;
    
    HMessage * msg = [self buildMessageWithActor:actor type:@"hAck" payload:hAck options:msgOptions didFailWithError:error];
    
    return msg;
}

- (HMessage *)buildMeasureWithActor:(NSString *)actor value:(NSString *)value unit:(NSString *)unit options:(HMessageOptions *)msgOptions didFailWithError:(NSError *__autoreleasing *)error {
    
    if(value == nil || [value length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing value", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    if(unit == nil || [unit length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing unit", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    HMeasure * hMeasure = [[HMeasure alloc] init];
    hMeasure.value = value;
    hMeasure.unit = unit;
    
    HMessage * msg = [self buildMessageWithActor:actor type:@"hMeasure" payload:hMeasure options:msgOptions didFailWithError:error];
    
    return msg;
}

#pragma mark - transport delegate

/**
 * notify a status
 */
- (void)statusNotification:(HStatus *)aStatus {
    [self notifyStatus:aStatus];
}

- (void)messageNotification:(HMessage *)aMessage {
    [self notifyMessage:aMessage];
}

- (void)errorNotification:(ResultStatus)resultStatus errorMsg:(NSString *)errorMsg refMsg:(NSString *)ref {
    HMessage *msg = [self buildResultWithActor:self.transport.options.jid ref:ref status:resultStatus result:errorMsg options:nil didFailWithError:nil];
    
    //check if there is callback because if there is not and it's an error, it means that a timeout of <0 was set
    NSArray * refComponents = [ref componentsSeparatedByString:@"#"];
    void(^callback)(HMessage*);
    if([refComponents count] == 2) {
        callback = [callbacks objectForKey:[refComponents objectAtIndex:1]];
    }
    
    if(callback)
        [self notifyMessage:msg];
}

- (void)errorNotification:(ResultStatus)resultStatus errorMsg:(NSString *)errorMsg refMsg:(NSString *)ref timeout:(long)timeout withBlock:(void(^)(HMessage*))callback {
    NSError *error = nil;
    HMessage *msg = [self buildResultWithActor:self.transport.options.jid ref:ref status:resultStatus result:errorMsg options:nil didFailWithError:&error];
    
    [self notifyMessage:msg withBlock:callback timeout:timeout];
}

#pragma mark - helper functions

// return a new autoreleased UUID string
- (NSString *)uuid
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    return uuidString;
}

/**
 * helper function used to call onStatus callback
 * calls to onStatus and onMessage callbacks are done sequentially on a queue using GCD.
 */
- (void)notifyStatus:(HStatus*)aStatus {
    DDLogVerbose(@"Status notification : %@", aStatus);
    dispatch_async(_notificationsQueue, ^() {
        if(self.onStatus)
            self.onStatus(aStatus);
    });
}

/**
 * helper function used to call onMessage callback
 * calls to onStatus and onMessage callbacks are done sequentially on a queue using GCD.
 */
- (void)notifyMessage:(HMessage*)aMessage {
    
    dispatch_async(_notificationsQueue, ^() {
        //find the callback if there is one
        NSArray * refComponents = [aMessage.ref componentsSeparatedByString:@"#"];
        void(^callback)(HMessage*);
        if([refComponents count] == 2) {
            callback = [callbacks objectForKey:[refComponents objectAtIndex:0]];
        }
        
        //first check if we have a callback for the message == if it's an answer
        //Don't forget to remove the callback once it's consumed
        if(callback) {
            [callbacks removeObjectForKey:[refComponents objectAtIndex:0]];
            callback(aMessage);
        } else if(self.onMessage){
            self.onMessage(aMessage);
        }
    });
}

- (void)notifyMessage:(HMessage*)aMessage withBlock:(void(^)(HMessage*))callback timeout:(long)timeout {
    if(callback && timeout >= 0) {
        dispatch_async(_notificationsQueue, ^() {        
            if(callback) {
                callback(aMessage);
            }
        });
    }
}

@end
