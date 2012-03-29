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


#import "HCSocketIO+HCTransportProtocol.h"
#import "HCReconnect.h"
#import "HCSocketIO+HCReconnectDelegate.h"
#import "HCErrors.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HCSocketIO (HCTransportProtocol)

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
        self.reconnectPlugin = [[HCReconnect alloc] initWithDelegate:self];
    }
    
    return self;
}

/**
 * see HCTransport protocol
 */
- (void)connect {
    self.autoreconnect = YES;
    
    //launch auto reconnect to connect
    [self.reconnectPlugin fireAutoReconnect];
}

/**
 * see HCTransport protocol
 */
- (void)disconnect {
    self.autoreconnect = NO;
    
    if ([self.socketio isConnected]) {
        //notify delegate connection
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"disconnecting", @"status",
                                  [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"link"];
        
        //call disconnect of huquitus node 
        self.userid = nil;
        self.sid = nil;
        self.rid = 0;
        [self.socketio sendEvent:@"disconnect" withData:nil];
        
        //close the link
        [self.socketio disconnect];
    }
}

/**
 * see HCTransport protocol
 */
- (NSString*)subscribeToChannel:(NSString*)channel_identifier {
    NSString * msgid = [NSString stringWithFormat:@"%@:subscribe", [self generateMsgid]];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:channel_identifier, @"channel",
                           msgid, @"msgid", nil];
    [self.socketio sendEvent:@"subscribe" withData:data];
    
    return msgid;
}

/**
 * see HCTransport protocol
 */
- (NSString*)unsubscribeFromChannel:(NSString*)channel_identifier {
    NSString * msgid = [NSString stringWithFormat:@"%@:unsubscribe", [self generateMsgid]];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:channel_identifier, @"channel",
                           msgid, @"msgid", nil];
    [self.socketio sendEvent:@"unsubscribe" withData:data];
    
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
    [self.socketio sendEvent:@"publish" withData:data];
    
    return msgid;
}

/**
 * see HCTransport protocol
 */
- (NSString *)getMessagesFromChannel:(NSString *)channel_identifier {
    NSString * msgid = [NSString stringWithFormat:@"%@:getMessages", [self generateMsgid]];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:channel_identifier, @"channel",
                           msgid, @"msgid", nil];
    
    [self.socketio sendEvent:@"get_messages" withData:data];
    
    return msgid;
}

@end
