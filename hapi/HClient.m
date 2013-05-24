/*
 * Copyright (c) Novedia Group 2012.
 *
 *    This file is part of Hubiquitus
 *
 *    Permission is hereby granted, free of charge, to any person obtaining a copy
 *    of this software and associated documentation files (the "Software"), to deal
 *    in the Software without restriction, including without limitation the rights
 *    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 *    of the Software, and to permit persons to whom the Software is furnished to do so,
 *    subject to the following conditions:
 *
 *    The above copyright notice and this permission notice shall be included in all copies
 *    or substantial portions of the Software.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 *    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 *    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 *    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 *    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 *    You should have received a copy of the MIT License along with Hubiquitus.
 *    If not, see <http://opensource.org/licenses/mit-license.php>.
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
#import "HLogLevel.h"
#import "NSDate+timestamp.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


@interface HClient () {
    dispatch_queue_t _notificationsQueue; /** queue used to sequentially notify client of a status or a message */
}
@property (nonatomic, strong) HTransport * transport;
@property (nonatomic, strong) NSMutableDictionary * callbacks;

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
@synthesize session_filter;

- (id)init {
    self = [super init];
    if(self) {
        _notificationsQueue = dispatch_queue_create("HClient.notifications.queue", NULL);
        self.transport = [[HTransport alloc] initWith:self];
        self.callbacks = [NSMutableDictionary dictionary];
        self.session_filter = [NSDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    dispatch_release(_notificationsQueue);
}


/**
 * Called to connect to hNode
 * This will only be called if disconnect. If not, it will return a hStatus with error code ALREADY_CONNECTED
 */
- (void)connectWithLogin:(NSString *)login password:(NSString *)password options:(HOptions *)options context:(NSDictionary *)context{
    if (!options)
        options = [[HOptions alloc] init];
    
    HTransportOptions * transportOpts = [[HTransportOptions alloc] initWithOptions:options];
    transportOpts.login = login;
    transportOpts.password = password;
    transportOpts.context = context;
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

- (NSString *)fullurn {
    return self.transport.fullurn;
}

- (NSString *)resource {
    return self.transport.resource;
}

- (void)send:(HMessage *)message withBlock:(void (^)(HMessage *))callback {
    if(!message) {
        [self errorNotification:RES_MISSING_ATTR errorMsg:@"Nil message" refMsg:@"-1" timeout:0 withBlock:callback];
        return;
    }
    
    if(!message.actor || message.actor.length <= 0) {
        [self errorNotification:RES_MISSING_ATTR errorMsg:@"Missing actor" refMsg:@"-1" timeout:message.timeout withBlock:callback];
        return;
    }
    
    message.sent = [[NSDate date] toTimestampInMs];
    message.msgid = @""; //msgid is set only if there is a timeout
    message.publisher = self.transport.fullurn;
    
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
                
                HMessage * timeoutResponse = [self buildResultWithActor:self.transport.fullurn ref:message.msgid status:RES_EXEC_TIMEOUT result:nil options:nil didFailWithError:nil];
                
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
    msgOptions.timeout = self.transport.options.msgTimeout;
    
    HMessage *cmd = [self buildCommandWithActor:@"session" cmd:@"hGetSubscriptions" params:nil filter:nil options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

- (void)subscribeToActor:(NSString *)actor withBlock:(void (^)(HMessage *))callback {
    if (callback == nil) {
        return;
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.msgTimeout;
    
    HMessage *cmd = [self buildCommandWithActor:actor cmd:@"hSubscribe" params:nil filter:nil options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

- (void)unsubscribeFromActor:(NSString *)actor withBlock:(void (^)(HMessage *))callback {
    
    if (callback == nil) {
        return;
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.msgTimeout;
    
    NSDictionary * channelToUnsub = [NSDictionary dictionaryWithObject:actor forKey:@"channel"];
    
    HMessage *cmd = [self buildCommandWithActor:@"session" cmd:@"hUnsubscribe" params:channelToUnsub filter:nil options:msgOptions didFailWithError:nil];

    [self send:cmd withBlock:callback];
}

- (void)setFilter:(NSDictionary *)filter withBlock:(void (^)(HMessage *))callback {
    if (callback == nil) {
        return;
    }
    
    if(!filter) {
        [self errorNotification:RES_MISSING_ATTR errorMsg:@"Missing filter" refMsg:@"-1" timeout:self.transport.options.msgTimeout withBlock:callback];
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.msgTimeout;
    self.session_filter = filter;
    
    HMessage *cmd = [self buildCommandWithActor:@"session" cmd:@"hSetfilter" params:filter filter:nil options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

- (void)setFilterWithString:(NSString *)filter withBlock:(void (^)(HMessage *))callback {
    if (callback == nil) {
        return;
    }
    
    HMessageOptions * msgOptions = [[HMessageOptions alloc] init];
    msgOptions.timeout = self.transport.options.msgTimeout;
    DDLogVerbose(@"Filter string : %@", filter);
    DDLogVerbose(@"Filter data : %@,", [filter dataUsingEncoding:NSUTF8StringEncoding]);
    NSDictionary * filterAsDictionnary = [NSJSONSerialization JSONObjectWithData:[filter dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    self.session_filter = filterAsDictionnary;
    DDLogVerbose(@"Filter json: %@", filterAsDictionnary);
    HMessage *cmd = [self buildCommandWithActor:@"session" cmd:@"hSetFilter" params:filterAsDictionnary filter:nil options:msgOptions didFailWithError:nil];
    
    [self send:cmd withBlock:callback];
}

#pragma mark - builders
- (HMessage *)buildMessageWithActor:(NSString *)actor type:(NSString *)type payload:(id)payload options:(HMessageOptions *)msgOptions didFailWithError:(NSError **)error {
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
        msg.publisher = self.transport.fullurn;
    
    if(msgOptions) {
        int priorityAsInt = msgOptions.priority;
        
        if(msgOptions.ref.length > 0) msg.ref = msgOptions.ref;
        if(msgOptions.convid.length > 0) msg.convid = msgOptions.convid;
        if(priorityAsInt >= 0) msg.priority = msgOptions.priority;
        if(msgOptions.relevance != nil) msg.relevance = msgOptions.relevance;
        if(msgOptions.persistent) msg.persistent = msgOptions.persistent;
        if(msgOptions.location != nil) msg.location = msgOptions.location;
        if(msgOptions.author.length > 0) msg.author = msgOptions.author;
        if(msgOptions.published != nil) msg.published = msgOptions.published;
        if(msgOptions.headers != nil) msg.headers = msgOptions.headers;
        if(msgOptions.timeout > 0) msg.timeout = msgOptions.timeout;
        
        if(msgOptions.relevanceOffset >= 0) {
            NSNumber * relevance = [NSNumber numberWithLongLong:([[[NSDate date] toTimestampInMs] longLongValue] + msgOptions.relevanceOffset)];
            msg.relevance = relevance;
        }
    }
    
    return msg;
}

- (HMessage *)buildCommandWithActor:(NSString *)actor cmd:(NSString *)cmd params:(NSDictionary *)params filter:(NSDictionary *)filter options:(HMessageOptions *)msgOptions didFailWithError:(NSError **)error {
    
    if(cmd == nil || [cmd length] <= 0) {
        if(error)
            *error = [NSError errorWithDomain:@"hBuilders" code:RES_MISSING_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing cmd", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    
    HCommand * hCommmand = [[HCommand alloc] init];
    hCommmand.cmd = cmd;
    hCommmand.params = params;
    hCommmand.filter = filter;

    HMessage *msg = [self buildMessageWithActor:actor type:@"hCommand" payload:hCommmand options:msgOptions didFailWithError:error];
    
    return msg;
}

- (HMessage *)buildResultWithActor:(NSString *)actor ref:(NSString *)ref status:(ResultStatus)status result:(id)result options:(HMessageOptions *)msgOptions didFailWithError:(NSError **)error {
    
    int statusAsInt = status;
    
    if(statusAsInt < 0) {
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
    HMessage *msg = [self buildResultWithActor:self.transport.fullurn ref:ref status:resultStatus result:errorMsg options:nil didFailWithError:nil];
    
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
    HMessage *msg = [self buildResultWithActor:self.transport.fullurn ref:ref status:resultStatus result:errorMsg options:nil didFailWithError:&error];
    
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
        if([refComponents count] >= 2) {
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
