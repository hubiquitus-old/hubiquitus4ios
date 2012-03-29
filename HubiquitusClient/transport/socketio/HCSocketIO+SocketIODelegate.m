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


#import "HCSocketIO+SocketIODelegate.h"
#import "HCSocketIO+Helper.h"
#import "HCErrors.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HCSocketIO (SocketIODelegate)

#pragma mark - socketio delegate protocol
/**
 * Socket.io-objc delegate method 
 * once connected to the server, this is called
 */
- (void) socketIODidConnect:(SocketIO *)socket; {
    //NSLog(@"HCSocketIO : connected to gateway");
    self.connectedToGateway = YES;
    
    //try to attach or connect to xmpp if we can't attach
    if (![self attach]) {
        [self connectToXmpp];
    }
}

/**
 * Socket.io-objc delegate method 
 * once disconnected from the server this is received
 */
- (void) socketIODidDisconnect:(SocketIO *)socket {
    //NSLog(@"HCSocketIO : Disconnected from the gateway");
    self.connectedToGateway = NO;
    self.connectedToXmpp = NO;
    
    //notify delegate connection
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"disconnected", @"status",
                              [NSNumber numberWithInt:NO_ERROR], @"code", nil];
    [self.delegate notifyIncomingMessage:resDict context:@"link"];
    
    [self.reconnectPlugin fireAutoReconnect];
}

/**
 * Socket.io-objc delegate method 
 * We should receive messages on this project
 */
- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    //NSLog(@"ERROR : did receive a message from the gateway, shouldn't have");
}

/**
 * Socket.io-objc delegate method 
 * We shouldn't receive json on this project
 */
- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
    //NSLog(@"ERROR : did receive JSon from the gateway, shouldn't have");
}

/**
 * Socket.io-objc delegate method 
 * Event are what we are litening for
 */
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    //NSLog(@"did receive event from the gateway : name %@, args %@", packet.name, packet.args);
    
    NSString * eventName = packet.name;
    NSArray * eventArgs = packet.args;
    
    //process each argument if there are multiple for some reason
    for (NSDictionary * arg in eventArgs) {
        [self processEvent:eventName withArg:arg];
    }
}

/**
 * Socket.io-objc delegate method 
 */
- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
    //NSLog(@"did send message to the gateway : name %@, args %@", packet.name, packet.args);
}

/**
 * Socket.io-objc delegate method 
 * We should retry auto connect if handshake fails
 */
- (void) socketIOHandshakeFailed:(SocketIO *)socket {
    //NSLog(@"Error : Handshake with the gateway failed : %@", socket);
    self.connectedToGateway = NO;
    self.connectedToXmpp = NO;
    [self.reconnectPlugin fireAutoReconnect];
}


@end
