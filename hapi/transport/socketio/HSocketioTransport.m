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

#import "HSocketioTransport.h"
#import "DDLog.h"
#import "Status.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @cond internal
 * @version 0.5.0
 * Socket.io transport layer
 */

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface HSocketioTransport() {
    Status _status;
}

@end

@implementation HSocketioTransport
@synthesize socketio;
@synthesize delegate, status;

- (id)initWithDelegate:(id<HTransportLayerDelegate>)aDelegate {
    self = [super init];
    if(self) {
        _status = DISCONNECTED;
        self.socketio = nil;
        self.delegate = nil;
        
        self.delegate = aDelegate;
    }
    
    return self;
}

/**
 * if we are disconnected, try fir to attach if possible
 * if not connect
 */
- (void)connectWithOptions:(HTransportOptions *)options {
    if(self.status == DISCONNECTED) {
        _status = CONNECTING;
        
        if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
            [self.delegate statusNotification:CONNECTING withErrorCode:NO_ERROR errorMsg:nil];
        }
        
        //TO ADD CONNECTION
    }
}

- (void)disconnect {
    if(self.status == CONNECTING || self.status == DISCONNECTED) {
        _status = DISCONNECTING;
        
        if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
            [self.delegate statusNotification:DISCONNECTING withErrorCode:NO_ERROR errorMsg:nil];
        }
        
        [self.socketio disconnect];
    }
}

- (void)send:(NSDictionary *)message {
    
}

#pragma mark - socketio delegate
- (void) socketIODidConnect:(SocketIO *)socket {
    
}

- (void) socketIODidDisconnect:(SocketIO *)socket {
    _status = DISCONNECTED;
    
    if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
        [self.delegate statusNotification:DISCONNECTED withErrorCode:NO_ERROR errorMsg:nil];
    }
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    for (NSDictionary* arg in packet.args) {
        if([packet.name isEqualToString:@"hMessage"]) {
            if([self.delegate respondsToSelector:@selector(messageNotification:)]) {
                [self.delegate messageNotification:arg];
            }
            
        } else if([packet.name isEqualToString:@"hStatus"]) {
            int status = [[arg objectForKey:@"status"] integerValue];
            int errorCode = [[arg objectForKey:@"errorCode"] integerValue];
            NSString * errorMsg = [arg objectForKey:@"errorMsg"];
            
            /** check if we didn't disconnect meanwhile */
            if (self.status == CONNECTING || self.status == CONNECTED) {
                _status = status;
                
                if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
                    [self.delegate statusNotification:status withErrorCode:errorCode errorMsg:errorMsg];
                }
            }
        }
    }
}

- (void) socketIOHandshakeFailed:(SocketIO *)socket {
    _status = DISCONNECTED;
    
    if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
        [self.delegate statusNotification:DISCONNECTED withErrorCode:TECH_ERROR errorMsg:@"SocketIO handshake failed"];
    }
}

@end

/**
 * @endcond
 */