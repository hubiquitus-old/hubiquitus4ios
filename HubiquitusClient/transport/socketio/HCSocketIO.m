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

#import "HCSocketIO.h"
#import "HCUtils.h"
#import "HCMessage.h"

/**
 *  @todo update to follow new hubiquitus node server protocol
 */

/**
 * @internal
 * A socketio implementation of the transport layer
 * works only with node.JS https://github.com/hubiquitus/hubiquitus-node
 * see HCTransport protocol for more informations
 */
@implementation HCSocketIO
@synthesize delegate;
@synthesize options;
@synthesize socketio;

/**
 * @internal
 * Connect to the hubiquitus-node gateway
 */
- (BOOL)establishLink {
    socketio = [[SocketIO alloc] initWithDelegate:self];
    
    //pick randomly 
    NSInteger port = [(NSNumber*)pickRandomValue(options.gateway.socketio.ports) integerValue];
    
    //connect to host
    [socketio connectToHost:options.gateway.socketio.endpoint onPort:port withParams:nil withNamespace:options.gateway.socketio.namespace];
    
    return YES;
}

#pragma mark - transport protocol

/**
 * see HCTransport protocol
 */
- (id)initWithOptions:(HCOptions *)theOptions delegate:(id<HCTransportDelegate>)aDelegate {
    self = [super init];
    
    if (self) {
        self.options = theOptions;
        self.delegate = aDelegate;
    }
    
    return self;
}

/**
 * see HCTransport protocol
 */
- (void)connect {
    //first of all connect to the gateway
    [self establishLink];
    
    NSString * host = options.domain;
    NSString * port = @"5222"; //default port
    
    //If a route is specified, the host and the port are different than the default
    if (options.route.length > 0) {
        NSArray * routeSlices = [options.route componentsSeparatedByString:@":"];
        host = [routeSlices objectAtIndex:0];
        if (routeSlices.count > 1) {
            port = [routeSlices objectAtIndex:1];
        }
    }
    
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                        options.username, @"jid",
                                        options.password, @"password",
                                        host, @"host",
                                        port, @"port",
                                        options.domain, @"domain",nil];
    
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:parameters, @"parameters", nil];
    
    //start the connection
    [socketio sendEvent:@"connect" withData:data];
}

/**
 * see HCTransport protocol
 */
- (void)disconnect {
    //close the link
    [socketio disconnect];
}

/**
 * see HCTransport protocol
 */
- (NSString*)subscribeToNode:(NSString*)node {
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:node, @"nodeName", nil];
    [socketio sendEvent:@"subscribe" withData:data];
    
    return @"";
}

/**
 * see HCTransport protocol
 */
- (NSString*)unsubscribeFromNode:(NSString*)node {
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:node, @"nodeName", nil];
    [socketio sendEvent:@"unsubscribe" withData:data];
    
    return @"";
}

/**
 * see HCTransport protocol
 */
- (NSString*)publishToNode:(NSString*)node item:(HCMessage*)item {
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:node, @"nodeName",
                                                                    [NSArray arrayWithObject:[item dataToDict]], @"items", nil];
    [socketio sendEvent:@"publish" withData:data];
    
    return @"";
}

#pragma mark - socketio delegate protocol
- (void) socketIODidConnect:(SocketIO *)socket; {
    NSLog(@"SocketIO : connected to gateway");
}

- (void) socketIODidDisconnect:(SocketIO *)socket {
    NSLog(@"SocketIO : Disconnected from the gateway");
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    NSLog(@"ERROR : did receive a message from the gateway, shouldn't have");
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
    NSLog(@"ERROR : did receive JSon from the gateway, shouldn't have");
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    NSLog(@"did receive event from the gateway : name %@, args %@", packet.name, packet.args);
    NSString * tmpName = @"link";
    NSDictionary * object = [NSDictionary dictionaryWithObjectsAndKeys:@"test1", @"status", @"test2", @"message", nil];
    if ([delegate respondsToSelector:@selector(notifyIncomingMessage:context:)]) {
        //for (id object in packet.args) {
            [delegate notifyIncomingMessage:object context:tmpName];
        //}
    }
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
    //NSLog(@"did send message to the gateway : name %@, args %@", packet.name, packet.args);
}

- (void) socketIOHandshakeFailed:(SocketIO *)socket {
    NSLog(@"Error : Handshake with the gateway failed : %@", socket);
}

@end
