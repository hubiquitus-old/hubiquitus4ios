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

#import "HSocketioTransport.h"
#import "DDLog.h"
#import "Status.h"
#import "ErrorCode.h"
#import "HLogLevel.h"
#import "NSDate+ISO8601.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @cond internal
 * @version 0.5.0
 * Socket.io transport layer
 */

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
 * if we are disconnected, try fire to attach if possible
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
            [self.delegate errorNotification:NOT_CONNECTED errorMsg:nil refMsg:[message objectForKey:@"msgid"]];
        }
    }
}

/**
 * start authentification on the server
 * Should be called after connection
 */
- (void)authenticate {
    NSDictionary * credentials = [NSDictionary dictionaryWithObjectsAndKeys:self.options.login, @"login", self.options.password, @"password", [[NSDate date] toISO8601],@"sent", nil];
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
        } else if([packet.name isEqualToString:@"attrs"]) {
            if([self.delegate respondsToSelector:@selector(attrsNotification:)]) {
                [self.delegate attrsNotification:arg];
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