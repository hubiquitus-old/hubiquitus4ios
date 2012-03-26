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
#import "HCErrors.h"

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
@synthesize connectedToGateway;
@synthesize rid;
@synthesize sid;
@synthesize userid;
@synthesize connectedToXmpp;
@synthesize autoreconnect;
@synthesize reconnectPlugin;

/**
 * @internal
 * Connect to the hubiquitus-node gateway
 */
- (BOOL)establishLink {
    socketio = [[SocketIO alloc] initWithDelegate:self];
    
    //pick randomly 
    NSInteger port = [(NSNumber*)pickRandomValue(options.gateway.socketio.ports) integerValue];
    
    NSLog(@"HCSocketIO Establishing a link to : %@, on port %d, with namespace : %@", options.gateway.socketio.endpoint, port, options.gateway.socketio.namespace);
    
    //connect to host
    [socketio connectToHost:options.gateway.socketio.endpoint onPort:port withParams:nil withNamespace:options.gateway.socketio.namespace];
    
    return YES;
}

- (NSString *)generateMsgid {
	NSString *result = nil;
	
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	if (uuid)
	{
		result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
	}
    
	return result;
}

- (BOOL)attach {
    //try to attach if a userid is set
    if (self.userid && ![self.userid isEqualToString:@""] && !self.connectedToXmpp) {
        //first try to reconnect to the gateway
        [self establishLink];
        
        
        NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.userid, @"userid",
                                     self.sid, @"sid",
                                     [NSString stringWithFormat:@"%d", self.rid], @"rid",
                                     nil];
        
        //start the connection
        NSLog(@"trying to send attach ");
        [socketio sendEvent:@"attach" withData:parameters];
        
        return YES;
    }

    return NO;
}

- (void)connectToXmpp {
    if (!self.connectedToXmpp) {
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
                                     options.username, @"userid",
                                     options.password, @"password",
                                     host, @"host",
                                     port, @"port",
                                     nil];
        
        //start the connection
        NSLog(@"trying to send connect ");
        [socketio sendEvent:@"hConnect" withData:parameters];
        
        //notify delegate connection
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connecting", @"status",
                                    [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
    }
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
        self.connectedToGateway = NO;
        self.userid = @"";
        self.rid = 0;
        self.sid = @"";
        self.connectedToXmpp = NO;
        
        //start reconnect plugin
        reconnectPlugin = [[HCReconnect alloc] initWithDelegate:self];
    }
    
    return self;
}

/**
 * see HCTransport protocol
 */
- (void)connect {
    self.autoreconnect = YES;
    [self reconnect];
    
    //launch auto reconnect just in case
    //[reconnectPlugin fireAutoReconnect];
}

/**
 * see HCTransport protocol
 */
- (void)disconnect {
    self.autoreconnect = NO;
    
    //call disconnect of huquitus node 
    self.userid = nil;
    self.sid = nil;
    self.rid = 0;
    [socketio sendEvent:@"hDisconnect" withData:nil];
    
    //close the link
    //[socketio disconnect];
}

/**
 * see HCTransport protocol
 */
- (NSString*)subscribeToChannel:(NSString*)channel_identifier {
    NSString * msgid = [NSString stringWithFormat:@"%@:subscribe", [self generateMsgid]];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:channel_identifier, @"channel",
                                                                    msgid, @"msgid", nil];
    [socketio sendEvent:@"subscribe" withData:data];
    
    return msgid;
}

/**
 * see HCTransport protocol
 */
- (NSString*)unsubscribeFromChannel:(NSString*)channel_identifier {
    NSString * msgid = [NSString stringWithFormat:@"%@:unsubscribe", [self generateMsgid]];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:channel_identifier, @"channel",
                                                                    msgid, @"msgid", nil];
    [socketio sendEvent:@"unsubscribe" withData:data];
    
    return msgid;
}

/**
 * see HCTransport protocol
 */
- (NSString*)publishToChannel:(NSString*)channel_identifier message:(HCMessage *)message {
    NSString * msgid = [NSString stringWithFormat:@"%@:publish", [self generateMsgid]];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:channel_identifier, @"channel",
                                                                    [message dataToDict], @"message",
                                                                    msgid, @"msgid", nil];
    [socketio sendEvent:@"publish" withData:data];
    
    return msgid;
}

/**
 * see HCTransport protocol
 */
- (NSString *)getMessagesFromChannel:(NSString *)channel_identifier {
    NSString * msgid = [NSString stringWithFormat:@"%@:getMessages", [self generateMsgid]];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:channel_identifier, @"channel",
                           msgid, @"msgid", nil];
    
    [socketio sendEvent:@"get_messages" withData:data];
    
    return msgid;
}

#pragma mark - socketio delegate protocol
- (void) socketIODidConnect:(SocketIO *)socket; {
    NSLog(@"HCSocketIO : connected to gateway");
    self.connectedToGateway = YES;
    
    //try to attach or connect to xmpp if we can't attach
    if (![self attach]) {
        [self connectToXmpp];
    }
}

- (void) socketIODidDisconnect:(SocketIO *)socket {
    NSLog(@"HCSocketIO : Disconnected from the gateway");
    self.connectedToGateway = NO;
    self.connectedToXmpp = NO;
    [reconnectPlugin fireAutoReconnect];
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    NSLog(@"ERROR : did receive a message from the gateway, shouldn't have");
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
    NSLog(@"ERROR : did receive JSon from the gateway, shouldn't have");
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    NSLog(@"did receive event from the gateway : name %@, args %@", packet.name, packet.args);
    
    NSString * eventName = packet.name;
    NSArray * eventArgs = packet.args;
    
    //process each argument if there multiple for some reason
    for (NSDictionary * arg in eventArgs) {
        [self processEvent:eventName withArg:arg];
    }
    
    //notify delegate connection
    //NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connecting", @"status",
    //                            [NSNumber numberWithInt:NO_ERROR], @"code", nil];
    //[self.delegate notifyIncomingMessage:notifDict context:@"link"];
    
    /*NSString * tmpName = @"link";
    NSDictionary * object = [NSDictionary dictionaryWithObjectsAndKeys:@"test1", @"status", @"test2", @"message", nil];
    if ([delegate respondsToSelector:@selector(notifyIncomingMessage:context:)]) {
        //for (id object in packet.args) {
            [delegate notifyIncomingMessage:object context:tmpName];
        //}
    }*/
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
    //NSLog(@"did send message to the gateway : name %@, args %@", packet.name, packet.args);
}

- (void) socketIOHandshakeFailed:(SocketIO *)socket {
    NSLog(@"Error : Handshake with the gateway failed : %@", socket);
    self.connectedToGateway = NO;
    self.connectedToXmpp = NO;
    [reconnectPlugin fireAutoReconnect];
}

#pragma mark - helper functions to deal with event received
- (void)processEvent:(NSString*)eventName withArg:(NSDictionary*)arg {
    if ([eventName isEqualToString:@"link"]) {
        [self processLinkEventWithArg:arg];
        
    } else if([eventName isEqualToString:@"attrs"]) {
        [self processAttrsEventWithArg:arg];
        
        //self.rid = self.rid + 1;
    }
}

- (void)processLinkEventWithArg:(NSDictionary *)arg {
    NSString * status = [arg objectForKey:@"status"];
    NSString * codeStr = [arg objectForKey:@"code"];
    NSNumber * code = [NSNumber numberWithInt:NO_ERROR];
    
    /* check that var are not empty */
    if (codeStr) {
        code = [NSNumber numberWithInt:[codeStr intValue]];
    }
    
    if (!status) {
        status = @"";
    }
    
    if ([status isEqualToString:@"connected"]) {
        //notify delegate connection
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connected", @"status",
                                    [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
        
        self.connectedToXmpp = YES;
    } else if ([status isEqualToString:@"disconnected"]) {
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"diconnected", @"status",
                                    [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
        
        self.connectedToXmpp = NO;
    } else if([status isEqualToString:@"attached"]) {
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"attached", @"status",
                                    [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
        
        self.connectedToXmpp = YES;
    } else if([status isEqualToString:@"error"]) {
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                    code, @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
        
        if ([code intValue] == FAILED_ATTACH) {
            self.userid = nil;
            self.sid = nil;
            self.rid = 0;
        }
        
        self.connectedToXmpp = NO;
    }
    
}

- (void)processResultEventWithArg:(NSDictionary*)arg {
    
}

- (void)processMessageEventWithArg:(NSDictionary*)arg {
    
}

- (void)processErrorEventWithArg:(NSDictionary*)arg {
    
}

- (void)processAttrsEventWithArg:(NSDictionary *)arg {
    NSString * attrsUserId = [arg objectForKey:@"userid"];
    NSString * attrsSid = [arg objectForKey:@"sid"];
    int attrsReqId = [[arg objectForKey:@"rid"] intValue];

    self.userid = attrsUserId;
    self.sid = attrsSid;
    self.rid = attrsReqId;
}

#pragma mark - helper functions to call delegate
- (void)notifyDelegateUnsubscribeWithMsgid:(NSString *)msgid fromChannel:(NSString *)channel {
    if ([self.delegate respondsToSelector:@selector(notifyIncomingMessage:context:)]) {
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"unsubscribe", @"type",
                                  channel, @"channel",
                                  msgid, @"msgid", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"result"];
    }
}

- (void)notifyDelegateSubscribeWithMsgid:(NSString *)msgid toChannel:(NSString *)channel {
    if ([self.delegate respondsToSelector:@selector(notifyIncomingMessage:context:)]) {
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"subscribe", @"type",
                                  channel, @"channel",
                                  msgid, @"msgid", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"result"];
    }
}

- (void)notifyDelegateErrorWithMsgid:(NSString *)msgid fromChannel:(NSString *)channel withCode:(NSNumber *)code ofType:(NSString *)type {
    NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:type, @"type",
                                code, @"code",
                                channel, @"channel",
                                msgid, @"msgid",
                                nil];
    [self.delegate notifyIncomingMessage:errorDict context:@"error"];
}

- (void)notifyDelegateMessagefromChannel:(NSString*)channel content:(NSString *)content {
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel",
                              content, @"message", nil];
    [self.delegate notifyIncomingMessage:resDict context:@"message"];
}

- (void)notifyDelegatePublishWithMsgid:(NSString *)msgid toChannel:(NSString *)channel {
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"publish", @"type",
                              channel, @"channel",
                              msgid, @"msgid", nil];
    
    [self.delegate notifyIncomingMessage:resDict context:@"result"];
}

#pragma mark - HCReconnect delegate
- (BOOL)shouldReconnect {
    return self.autoreconnect;
}

- (BOOL)connected {
    return self.connectedToGateway && self.connectedToXmpp;
}

/**
 * Used by HCReconnect to reconnect
 */
- (void)reconnect {
    self.autoreconnect = YES;
    //first of all connect to the gateway
    if (!self.connectedToGateway) {
        [self establishLink];
    } else if (self.connectedToGateway && !self.connectedToXmpp) {
        if (![self attach]) {
            [self connectedToXmpp];
        }
    }
    
    //launch auto reconnect just in case
    [reconnectPlugin fireAutoReconnect];
}

@end
