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

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

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

/**
 * Called to connect to hNode
 * This will only be called if disconnect. If not, it will return a hStatus with error code ALREADY_CONNECTED
 */
- (void)connectWithPublisher:(NSString *)publisher password:(NSString *)password options:(HOptions *)options {
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
    message.msgid = [self uuid];
    message.publisher = self.transport.options.jid;
    
    if(callbacks != nil && message.timeout > 0) {
        [self.callbacks setObject:callback forKey:message.msgid];
        
        //add a timeout handler
        dispatch_source_t _connectTimer = NULL; /** timer used for auto connect attempts */
        dispatch_source_set_timer(_connectTimer, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                                  message.timeout * NSEC_PER_MSEC, 1);
        dispatch_source_set_event_handler(_connectTimer, ^{
            if([callbacks objectForKey:message.msgid]) {
                [callbacks removeObjectForKey:message.msgid];
                
                //USE RESULT BUILDER TO SEND RESPONSE TIMEOUT
                HMessage * timeoutResponse = [[HMessage alloc] init];
                callback(timeoutResponse);
            }
        });
    }
    
    [self.transport send:message];
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
            callback = [callbacks objectForKey:[refComponents objectAtIndex:1]];
        }
        
        //first check if we have a callback for the message == if it's an answer
        //Don't forget to remove the callback once it's consumed
        if(callback) {
            [callbacks removeObjectForKey:[refComponents objectAtIndex:1]];
            callback(aMessage);
        } else {
            self.onMessage(aMessage);
        }
    });
}

@end
