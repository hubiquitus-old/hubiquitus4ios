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

#import "HTransport.h"
#import "HReachability.h"
#import "HTransportLayer.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "HUtils.h"
#import "HSocketioTransport.h"
#import "HLogLevel.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @cond internal
 * @version 0.5.0
 * Transport. Call the chosen transport layer and manage autoreconnect
 */

@interface HTransport () {
@private
    Status _status; /** status of the connection */
    
    dispatch_queue_t _connectQueue; /** queue that will handle connections and reconnections requests */
    dispatch_source_t _connectTimer; /** timer used for auto connect attempts */

    int _autoConnectDelay;
    bool _autoConnectTimerEnabled;
}

@property (nonatomic) BOOL autoConnect;
@property (nonatomic, strong) HReachability * reachability;
@property (nonatomic, strong) id<HTransportLayer> transportLayer;

- (void)setupAutoConnect;

@end



@implementation HTransport
@synthesize autoConnectDelay = _autoConnectDelay;
@synthesize delegate, status = _status;
@synthesize reachability, autoConnect;
@synthesize options;
@synthesize transportLayer;
@synthesize fullurn;
@synthesize resource;

- (id)initWith:(id<HTransportDelegate>)aDelegate {
    self = [super init];
    if(self) {
        self.delegate = aDelegate;
        _status = DISCONNECTED;
        
        [self setupAutoConnect];
        
        self.autoConnectDelay = 2; //2s by default
        self.autoConnect = false;
    }
    
    return self;
}

/**
 * init transport layer and start autoConnect system to connect
 */
- (void)connectWithOptions:(HTransportOptions*)someOptions {   
    //check if we are not connected
    if(self.status != DISCONNECTED && self.status != DISCONNECTING) {
        int errorCode = hError.ALREADY_CONNECTED;
        if (self.status == CONNECTING) {
            errorCode = hError.CONN_PROGRESS;
        }
        
        [self notifyStatus:self.status withErrorCode:errorCode errorMsg:@"Already connected or trying to connect"];
        return;
    }
    
    //Check if we have a transport
    if (someOptions.transport.length <= 0) {
        [self notifyStatus:self.status withErrorCode:hError.TECH_ERROR errorMsg:@"No valid endpoint. Endpoint should follow pattern : http://domain:port"];
        return;
    }
    
    //finally we can try to connect
    self.options = someOptions;
    
    //create transport layer : by default socketio
    if(self.transportLayer == nil) {
        self.transportLayer = [[HSocketioTransport alloc] initWithDelegate:self];
    }
    
    self.autoConnect = YES;
    
    [reachability startNotifier];
    
    //start auto connect system
    @synchronized(self) {
        if (_connectTimer != NULL  && !_autoConnectTimerEnabled) {
            DDLogVerbose(@"Starting auto connect system to connect");
            _autoConnectTimerEnabled = YES;
            dispatch_resume(_connectTimer);
        }
    }
}

/**
 * stop autoConnect and wait for auto disconnect
 */
- (void)disconnect {
    //stop autoconnect timer if we are trying to connect
    [reachability stopNotifier];
    self.autoConnect = NO;
    
    if(self.status != DISCONNECTING && self.status != DISCONNECTED) {
        //start auto connect system
        @synchronized(self) {
            if (_connectTimer != NULL && !_autoConnectTimerEnabled) {
                DDLogVerbose(@"Starting auto connect system to disconnect");
                _autoConnectTimerEnabled = YES;
                dispatch_resume(_connectTimer);
            }
        }
    } else {
        if (self.status == DISCONNECTED) {
            [self notifyStatus:self.status withErrorCode:hError.NOT_CONNECTED errorMsg:nil];
        }
    }
    
}

- (void)send:(HMessage *)message {
    DDLogVerbose(@"sending message : %@", message);
    if(self.status == CONNECTED) {
        [self.transportLayer send:message];
    } else {
        if([self.delegate respondsToSelector:@selector(errorNotification:errorMsg:refMsg:)]) {
            [self errorNotification:hError.NOT_CONNECTED errorMsg:[NSString stringWithFormat:@"cannot send message while status is : %d",self.status] refMsg:message.ref];
        }
    }
}

- (void)dealloc {
    dispatch_source_cancel(_connectTimer);
    dispatch_release(_connectTimer);
    dispatch_release(_connectQueue);
    [reachability stopNotifier];
}

#pragma mark - connectInternal

/**
 * Check if it need to disconnect or connect. If it need to connect, it first waits for reachability
 */
- (void)tryToConnectDisconnect {
    DDLogVerbose(@"Auto connect system in progress : autoConnect %d, connection status : %d, transportLayer status %d", self.autoConnect, self.status, self.transportLayer.status);
    @try {
        if(!self.autoConnect && transportLayer.status == CONNECTED) {
            [self.transportLayer disconnect]; //well make sure we disconnect
        } else if(self.autoConnect && transportLayer.status == DISCONNECTED) {
            [self.transportLayer connectWithOptions:self.options];
        } else if(!autoConnect && transportLayer.status == DISCONNECTED) {
            [self stopTimer];
        } else if(autoConnect && transportLayer.status == CONNECTED) {
            [self stopTimer];
        }
    } @catch (NSException * err) {
        DDLogError(@"Fatal error while trying to connect : %@. Aborting", err);
        self.autoConnect = NO;
        if (self.transportLayer.status == CONNECTED || self.transportLayer.status == CONNECTING || self.transportLayer.status == DISCONNECTING) {
            [self.transportLayer disconnect];
            
            [self notifyStatus:DISCONNECTED withErrorCode:hError.TECH_ERROR errorMsg:[NSString stringWithFormat:@"Fatal error occured while trying to connect : %@", err]];
        }
    }
    
    
}

#pragma mark - autoConnect

/**
 * change delay for auto connect attemps
 */
- (void)setAutoConnectDelay:(int)autoConnectDelay {
    //if we update it, update timer too
    _autoConnectDelay = autoConnectDelay;
    
    dispatch_source_set_timer(_connectTimer, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                              self.autoConnectDelay * NSEC_PER_SEC, 1);
}

/**
 * stop the auto connect timer
 */
- (void)stopTimer {
    @synchronized(self) {
        if (_autoConnectTimerEnabled) {
            dispatch_suspend(_connectTimer);
            _autoConnectTimerEnabled = NO;
        }
    }
}

/**
 * Set the auto connect. Auto connect start a connection and try to connect until it can
 */
- (void)setupAutoConnect {
    //set reachability to disable timer until we have an uplink
    reachability = [HReachability reachabilityForInternetConnection];
    
    //setup
    _connectQueue = dispatch_queue_create("HTransport.connect.queue", NULL);
    
    // create our timer source, it fires to notify that we should do an attempt to connect
    _connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _connectQueue);
    
    // so just fill in the initial time).
    dispatch_source_set_timer(_connectTimer, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                              self.autoConnectDelay * NSEC_PER_SEC, 1);
    
    //we have to make sure we call dispatch_suspend or dispatch_resume only one time because 
    //it has a counter of all. Each dispatch_suspend should be balanced by a dispatch_resume
    _autoConnectTimerEnabled = NO;
    
    // Try to autoconnect when it fires
    dispatch_source_set_event_handler(_connectTimer, ^{
        [self tryToConnectDisconnect];
    });
    
    //register to reachibility notification
    [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:
            {
                DDLogVerbose(@"Reachability unavailable");
                [self stopTimer];
                break;
            }
                
            case ReachableViaWWAN:
            {
                DDLogVerbose(@"Reachability available through GSM");
                [self tryToConnectDisconnect];
                break;
            }
            case ReachableViaWiFi:
            {
                DDLogVerbose(@"Reachability available through Wifi");
                [self tryToConnectDisconnect];
                break;
            }
        }
        
    }];
    
}

#pragma mark - Transport layer delegate

- (void)statusNotification:(Status)aStatus withErrorCode:(int)anErrorCode errorMsg:(NSString *)anErrorMsg {
    
    //if credentials are refused, we disconnect and stop auto connect system
    if(aStatus == hError.AUTH_FAILED)
        [self disconnect];
    
    if(aStatus == DISCONNECTED) {
        self.fullurn = nil;
        self.resource = nil;
    }
    
    if(aStatus != CONNECTED || (aStatus == CONNECTED && fullurn)) {
        _status = aStatus;
        [self notifyStatus:aStatus withErrorCode:anErrorCode errorMsg:anErrorMsg];
    }
        
}

- (void)messageNotification:(NSDictionary *)message {
    DDLogVerbose(@"Message received : %@", message);
    if([self.delegate respondsToSelector:@selector(messageNotification:)]) {
        HMessage * hMsg = [[HMessage alloc] initWithDictionary:message];
        [self.delegate messageNotification:hMsg];
    }
}

- (void)errorNotification:(ResultStatus)resultStatus errorMsg:(NSString *)errorMsg refMsg:(NSString *)ref {
    DDLogVerbose(@"Error happened : errorCode %d, errorMsg %@, ref %@",resultStatus, errorMsg, ref);
    if([self.delegate respondsToSelector:@selector(errorNotification:errorMsg:refMsg:)]) {
        [self.delegate errorNotification:resultStatus errorMsg:errorMsg refMsg:ref];
    }
}

- (void)attrsNotification:(NSDictionary *)attr {
    DDLogVerbose(@"Attr received : %@", attr);
    if(attr) {
        self.fullurn = [attr objectForKey:@"publisher"];
        if([attr objectForKey:@"publisher"])
            self.resource = [splitUrn(fullurn) objectForKey:@"resource"];
        
        if(_status == CONNECTING && self.transportLayer.status == CONNECTED) {
            _status = CONNECTED;
            [self notifyStatus:CONNECTED withErrorCode:0 errorMsg:nil];
        }
    }
}

#pragma mark - Helper functions

/**
 * notify the delegate of a status update
 */
- (void)notifyStatus:(Status)aStatus withErrorCode:(int)anErrorCode errorMsg:(NSString *)anErrorMsg {
    HStatus * hStatus = [[HStatus alloc] init];
    hStatus.status = aStatus;
    hStatus.errorCode = anErrorCode;
    hStatus.errorMsg = anErrorMsg;
    
    if([self.delegate respondsToSelector:@selector(statusNotification:)]) {
        [self.delegate statusNotification:hStatus];
    }
}

@end

/**
 * @endcond
 */