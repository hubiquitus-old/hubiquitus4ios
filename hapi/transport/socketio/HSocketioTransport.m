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
#import "ErrorCode.h"

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
@property HTransportOptions * options;

@end

@implementation HSocketioTransport
@synthesize socketio;
@synthesize delegate, status = _status;
@synthesize options;

- (id)initWithDelegate:(id<HTransportLayerDelegate>)aDelegate {
    self = [super init];
    if(self) {
        _status = DISCONNECTED;
        self.socketio = [[SocketIO alloc] initWithDelegate:self];
        
        self.delegate = aDelegate;
    }
    
    return self;
}

/**
 * if we are disconnected, try fir to attach if possible
 * if not connect
 */
- (void)connectWithOptions:(HTransportOptions *)someOptions {
    if(self.status == DISCONNECTED) {
        _status = CONNECTING;
        
        if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
            [self.delegate statusNotification:CONNECTING withErrorCode:NO_ERROR errorMsg:nil];
        }
        self.options = someOptions;
        NSURL *endpoint = self.options.endpoint;
        [self.socketio connectToHost:endpoint.host onPort:[endpoint.port intValue]];
    }
}

- (void)disconnect {
    if(self.status == CONNECTED || self.status == CONNECTING) {
        _status = DISCONNECTING;
        
        if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
            [self.delegate statusNotification:DISCONNECTING withErrorCode:NO_ERROR errorMsg:nil];
        }
        
        [self.socketio disconnect];
    }
}

- (void)send:(NSDictionary *)message {
    if(self.status == CONNECTED) {
        [self.socketio sendEvent:@"hMessage" withData:message]; 
    } else {
        if([self.delegate respondsToSelector:@selector(errorNotification:errorMsg:)]) {
            [self.delegate errorNotification:NOT_CONNECTED errorMsg:nil refMsg:[message objectForKey:@"msg"]];
        }
    }
}

/**
 * start authentification on the server
 * Should be called after connection
 */
- (void)authenticate {
    NSDictionary * credentials = [NSDictionary dictionaryWithObjectsAndKeys:self.options.jid, @"publisher", self.options.password, @"password", nil];
    [self.socketio sendEvent:@"hConnect" withData:credentials];
}

#pragma mark - socketio delegate
- (void) socketIODidConnect:(SocketIO *)socket {
    DDLogVerbose(@"transport layer did connect");
    [self authenticate];
}

- (void) socketIODidDisconnect:(SocketIO *)socket {
    DDLogVerbose(@"transport layer did disconnect");
    _status = DISCONNECTED;
    
    if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
        [self.delegate statusNotification:DISCONNECTED withErrorCode:NO_ERROR errorMsg:nil];
    }
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    DDLogVerbose(@"transport layer did receive event");
    for (NSDictionary* arg in packet.args) {
        if([packet.name isEqualToString:@"hMessage"]) {
            if([self.delegate respondsToSelector:@selector(messageNotification:)]) {
                [self.delegate messageNotification:arg];
            }
            
        } else if([packet.name isEqualToString:@"hStatus"]) {
            int aStatus = [[arg objectForKey:@"status"] integerValue];
            int errorCode = [[arg objectForKey:@"errorCode"] integerValue];
            NSString * errorMsg = [arg objectForKey:@"errorMsg"];
            
            /** check if we didn't disconnect meanwhile */
            if (self.status == CONNECTING || self.status == CONNECTED) {
                _status = aStatus;
                
                if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
                    [self.delegate statusNotification:aStatus withErrorCode:errorCode errorMsg:errorMsg];
                }
            }
        }
    }
}

- (void) socketIOHandshakeFailed:(SocketIO *)socket {
    DDLogVerbose(@"transport layer handshake failed");
    _status = DISCONNECTED;
    
    if([self.delegate respondsToSelector:@selector(statusNotification:withErrorCode:errorMsg:)]) {
        [self.delegate statusNotification:DISCONNECTED withErrorCode:TECH_ERROR errorMsg:@"SocketIO handshake failed"];
    }
}

@end

/**
 * @endcond
 */