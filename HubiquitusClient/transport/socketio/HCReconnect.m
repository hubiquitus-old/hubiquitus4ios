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


#import "HCReconnect.h"
#import "HCReachability.h"

@interface HCReconnect () {
@private
    dispatch_queue_t _reconnectQueue;
    dispatch_source_t _timer;
    int _attemptDelay;
    HCReachability * reachability;
    BOOL _timerRunning;
}

- (void)stopTimer;
- (void)tryReconnect;

@end

@implementation HCReconnect

@synthesize attemptDelay = _attemptDelay;
@synthesize delegate;

- (id)initWithDelegate:(id<HCReconnectDelegate>)aDelegate {
    return [self initWithDelegate:aDelegate attemptDelay:2];
}

- (id)initWithDelegate:(id<HCReconnectDelegate>)aDelegate attemptDelay:(int)anAttemptDelay {
    self = [super init];
    if (self) {
        self.delegate = aDelegate;
        _attemptDelay = anAttemptDelay;
        
        //set reachability to disable timer until we have an uplink
        reachability = [HCReachability reachabilityForInternetConnection];
    
        //setup
        _reconnectQueue = dispatch_queue_create("HCReconnect.queue", NULL);
        
        // create our timer source
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _reconnectQueue);

        // so just fill in the initial time).
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                                  _attemptDelay * NSEC_PER_SEC, 1);
        
        // Try to reconnect when it fires
        dispatch_source_set_event_handler(_timer, ^{
            NSLog(@"timer called");
            [self tryReconnect];
        });
        
        //we have to make sure we call dispatch_suspend or dispatch_resume only one time because 
        //it has a counter of all. Each dispatch_suspend should be balanced by a dispatch_resume
        _timerRunning = NO;
        
        //start checking reachability
        [reachability startNotifier];
        
        //register to reachibility notification
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            NetworkStatus netStatus = [reachability currentReachabilityStatus];
            switch (netStatus)
            {
                case NotReachable:
                {
                    [self stopTimer];
                    break;
                }
                    
                case ReachableViaWWAN:
                {
                    [self fireAutoReconnect];
                    break;
                }
                case ReachableViaWiFi:
                {
                    [self fireAutoReconnect];
                    break;
                }
            }
            
        }];

    }
    
    return self;
}

- (void)stopTimer {
    NSLog(@"Call to stopTime with _timerRunning status : %d", _timerRunning);
    @synchronized(self) {
        if (_timerRunning) {
            NSLog(@"stopping timer");
            dispatch_suspend(_timer);
            _timerRunning = NO;
        }
    }
}

- (void)fireAutoReconnect {
    // now that our timer is all set to go, start it
    NSLog(@"call to fireAutoReconnect, timerRunning status : %d", _timerRunning);
    @synchronized(self) {
        if (!_timerRunning) {
            NSLog(@"restart timer");
            _timerRunning = YES;
            dispatch_resume(_timer);
        }
    }
}

- (void)dealloc {
    dispatch_source_cancel(_timer);
    dispatch_release(_timer);
    dispatch_release(_reconnectQueue);
    [reachability stopNotifier];
}

#pragma mark - private functions

- (void)tryReconnect {
    NSLog(@"Trying a reconnect");
    //check first if we should reconnect and of course if we have reachbility
    if ([reachability currentReachabilityStatus] != NotReachable && delegate && [delegate respondsToSelector:@selector(shouldReconnect)]) {
        NSLog(@"Trying reachability, delegate and selector ok");
        if ([delegate shouldReconnect] && [delegate respondsToSelector:@selector(connected)]) {
            if ([delegate connected]) {
                //stop time if connected
                [self stopTimer];
            } else {                
                if ([delegate respondsToSelector:@selector(connect)]) {
                    [delegate reconnect];
                }
            }
        } else {
            [self stopTimer]; 
        }
    } else {
        [self stopTimer];
    }    
}

@end
