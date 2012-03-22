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

#import "HCXmpp+HCTransportProtocol.h"
#import "HCXmpp+XMPPUtils.h"
#import "HCErrors.h"
#import "SBJsonWriter.h"

@implementation HCXmpp (HCTransportProtocol)

/**
 * see HCTransport protocol
 */
- (id)initWithOptions:(HCOptions *)theOptions delegate:(id<HCTransportDelegate>)aDelegate {
    self = [self init];
    
    if (self) {
        self.options = theOptions;
        self.delegate = aDelegate;
        self.isXmppConnected = NO;
        self.isAuthenticated = NO;
        
        [self setupStream];
    }
    
    return self;
}

/**
 * see HCTransport protocol
 */
- (void)connect {
    if (!self.isXmppConnected) {
        //set hostname and host port
        if (self.options.routeDomain != nil) {
            [self.xmppStream setHostName:self.options.routeDomain];
        } else if (self.options.domain != nil) {
            [self.xmppStream setHostName:self.options.domain];
        }
        
        if (self.options.routePort != nil) {
            [self.xmppStream setHostPort:[self.options.routePort intValue]];
        }
        
        self.service = [XMPPJID jidWithUser:nil domain:[NSString stringWithFormat:@"%@%@", @"pubsub.", [self.xmppStream hostName]] resource:nil];
        
        //setup extensions
        
        //PubSub extension : enable publish subscribe XEP-0060 xmpp extension
        self.xmppPubSub = [[XMPPPubSub alloc] initWithServiceJID: self.service];
        
        // Activate xmpp modules
        [self.xmppPubSub activate:self.xmppStream];
        
        //add delegate
        [self.xmppPubSub addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        NSString * jid = self.options.username;
        NSString * password = self.options.password;
        
        //notify delegate connection
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connecting", @"status",
                                  [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"link"];
        
        
        if(![self.xmppStream isConnected] && jid != nil && password != nil) {
            [self.xmppStream setMyJID:[XMPPJID jidWithString:jid]];
            
            NSError * error = nil;
            if (![self.xmppStream connect:&error]) {
                NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                            [NSNumber numberWithInt:CONNECTION_FAILED], @"code", nil];
                [self.delegate notifyIncomingMessage:errorDict context:@"link"];
                
                NSLog(@"HCXmpp error on connect : %@", error);
            }
            
        }
    }
}

/**
 * see HCTransport protocol
 */
- (void)disconnect {
    if (self.isXmppConnected) {
        //notify delegate connection
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"disconnecting", @"status",
                                  [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"link"];
        //go offline
        [self goOffline];
        [self.xmppStream disconnect];
    }
    
    
}

/**
 * see HCTransport protocol
 */
- (NSString*)subscribeToChannel:(NSString*)channel_identifier {
    NSString * msgid = [self.xmppPubSub getSubscriptionsForNode:channel_identifier];
    
    //it's a little tricky
    //first we have to getAllSubscriptions then if we are not already subscribed, we subscribe, but we return the msgid of call to getAllSubscriptions
    //To return in the acknoledgement of subscribe the right msgid (which is the getAllSubscriptions msgid) we save it int the data of a callback
    //To do this, we put a callback once we get subscriptions
    //then we put another callback on subscription
    
    //add a block on this function return
    void(^block)(XMPPIQ * iq, NSDictionary * data) = ^(XMPPIQ * iq, NSDictionary * data) {  
        BOOL hasSubscriptions = [self resultIqHasSubscriptions:iq];
        if (hasSubscriptions) {
            //set error default value
            NSString * type = @"subscribe";
            NSNumber * code = [NSNumber numberWithInt:ALREADY_SUBSCRIBED];
            NSString * channel = channel_identifier;
            NSString * errorMsgid = msgid;
            
            //notify delegate of error
            [self notifyDelegateErrorWithMsgid:errorMsgid fromChannel:channel withCode:code ofType:type];
            
        } else {
            NSString * subMsgid = [self.xmppPubSub subscribeToNode:channel_identifier withOptions:nil];
             void(^block)(XMPPIQ * iq, NSDictionary * data) = ^(XMPPIQ * iq, NSDictionary * data) {
                 [self notifyDelegateSubscribeWithMsgid:[data objectForKey:@"msgid"] toChannel:[data objectForKey:@"channel"]];
             };
            
            //add the block to the result callback
            [self addResultBlockForMsgid:subMsgid withData:data block:block];
        }
    };
    
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:msgid, @"msgid",
                                                                    channel_identifier, @"channel", nil];
    
    //add the block to the result callback
    [self addResultBlockForMsgid:msgid withData:data block:block];
    
    return msgid;
}

/**
 * see HCTransport protocol
 */
- (NSString*)unsubscribeFromChannel:(NSString*)channel_identifier {
    NSString * msgid = [self.xmppPubSub unsubscribeFromNode:channel_identifier];
    
    //add a block to notify on result
    void(^block)(XMPPIQ * iq, NSDictionary * data) = ^(XMPPIQ * iq, NSDictionary * data) {    
        [self notifyDelegateUnsubscribeWithMsgid:[data objectForKey:@"msgid"] fromChannel:[data objectForKey:@"channel"]];
    };
    
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:msgid, @"msgid",
                                                                    channel_identifier, @"channel", nil];
    
    //add the block to the result callback
    [self addResultBlockForMsgid:msgid withData:data block:block];
    
    return msgid;
}

/**
 * see HCTransport protocol
 */
- (NSString*)publishToChannel:(NSString*)channel_identifier message:(HCMessage*)message {
    SBJsonWriter * jsonWriter = [[SBJsonWriter alloc] init];
    NSString * messageStr = [jsonWriter stringWithObject:[message dataToDict]];
    
    NSXMLElement * entry = [NSXMLElement elementWithName:@"entry"];
    [entry setStringValue:messageStr];
    
    return [self.xmppPubSub publishToNode:channel_identifier entry:entry];
}

/**
 * see HCTransport protocol
 */
- (NSString *)getMessagesFromChannel:(NSString *)channel_identifier {
    return [self.xmppPubSub allItemsForNode:channel_identifier];
}


@end
