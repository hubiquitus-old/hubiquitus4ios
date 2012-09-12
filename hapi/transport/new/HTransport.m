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

#import "HTransport.h"
#import "HReachability.h"
#import "HTransportLayer.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

/**
 * @cond internal
 * @version 0.5.0
 * Transport. Call the chosen transport layer and manage autoreconnect
 */

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

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

- (id)initWith:(id<HTransportDelegate>)aDelegate {
    self = [super init];
    if(self) {
        self.delegate = aDelegate;
        _status = DISCONNECTED;
        
        self.autoConnectDelay = 2; //2s by default
        self.autoConnect = false;
        
        [self setupAutoConnect];
    }
    
    return self;
}

- (void)connectWithOptions:(HTransportOptions*)someOptions {
    self.options = someOptions;
    self.autoConnect = YES;
    
    [reachability startNotifier];
    
    //start auto connect system
    @synchronized(self) {
        if (!_connectTimer) {
            _autoConnectTimerEnabled = YES;
            dispatch_resume(_connectTimer);
        }
    }
}

- (void)disconnect {
    //stop autoconnect timer if we are trying to connect
    [reachability stopNotifier];
    self.autoConnect = NO;
    [self tryToConnectDisconnect];
}

- (void)send:(HMessage *)message {
    DDLogVerbose(@"sending message : %@", message);
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
    DDLogVerbose("Auto connect system in progress : autoConnect %d, connection status : %d, transportLayer status %d", self.autoConnect, self.status, self.transportLayer.status);
    if(!self.autoConnect && transportLayer.status == CONNECTED) {
        [self.transportLayer disconnect]; //well make sure we disconnect
    } else if(self.autoConnect && transportLayer.status == DISCONNECTED) {
        [self.transportLayer connectWithOptions:self.options];
    } else if(!autoConnect && transportLayer.status == DISCONNECTED) {
        [self stopTimer];
    } else if(autoConnect && transportLayer.status == CONNECTED) {
        [self stopTimer];
    }
}

#pragma mark - autoConnect

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
    
    //start checking reachability
    //[reachability startNotifier];
    
    //register to reachibility notification
    [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:
            {
                DDLogVerbose("Reachability unavailable");
                [self stopTimer];
                break;
            }
                
            case ReachableViaWWAN:
            {
                DDLogVerbose("Reachability available through GSM");
                [self tryToConnectDisconnect];
                break;
            }
            case ReachableViaWiFi:
            {
                DDLogVerbose("Reachability available through Wifi");
                [self tryToConnectDisconnect];
                break;
            }
        }
        
    }];
    
}

#pragma mark - 

#pragma mark - Transport layer delegate


- (void)statusNotification:(Status)aStatus withErrorCode:(ErrorCode)anRrrorCode errorMsg:(NSString *)anErrorMsg {
    _status = aStatus;
}

- (void)messageNotification:(NSString *)message {
    
}

@end

/**
 * @endcond
 */