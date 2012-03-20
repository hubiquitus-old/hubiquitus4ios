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

#import "HCXmpp.h"
#import "HCErrors.h"
#import "SBJson.h"
#import "XMPPPubSub+Utils.h"

/**
 * @internal
 * An XMPP implementation of the transport layer
 * see HCTransport protocol for more informations
 */
@implementation HCXmpp
@synthesize delegate;
@synthesize options;
@synthesize xmppStream, xmppReconnect, xmppPubSub;
@synthesize isXmppConnected, isAuthenticated;
@synthesize service;
@synthesize msgidChannel;

/**
 * init the xmpp stream, add the extensions we need
 * This doesn't connect
 * Should be called only once
 */
- (void)setupStream {
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		xmppStream.enableBackgroundingOnSocket = options.gateway.xmpp.runInBackground;
	}
#endif
    //setup extensions
    
    //XMPPReconnect, monitors for "accidental diconnections" and automatically reconnects.
	xmppReconnect = [[XMPPReconnect alloc] init];
    
	// Activate xmpp modules
    
	[xmppReconnect activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

/**
 * shutdown xmpp stream and disable extensions
 */
- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	
	[xmppReconnect deactivate];
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
}


- (void)dealloc {
    [self teardownStream];
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

/******************************************************************************************************************/
#pragma mark - transport protocol
/******************************************************************************************************************/

/**
 * see HCTransport protocol
 */
- (id)initWithOptions:(HCOptions *)theOptions delegate:(id<HCTransportDelegate>)aDelegate {
    self = [super init];
    
    if (self) {
        self.options = theOptions;
        self.delegate = aDelegate;
        self.isXmppConnected = NO;
        self.isAuthenticated = NO;
        
        self.msgidChannel = [NSMutableDictionary dictionary];
        
        [self setupStream];
    }
    
    return self;
}

/**
 * see HCTransport protocol
 */
- (void)connect {
    //set hostname and host port
    if (options.routeDomain != nil) {
        [xmppStream setHostName:options.routeDomain];
    } else if (options.domain != nil) {
        [xmppStream setHostName:options.domain];
    }
    
    if (options.routePort != nil) {
        [xmppStream setHostPort:[options.routePort intValue]];
    }
    
    self.service = [XMPPJID jidWithUser:nil domain:[NSString stringWithFormat:@"%@%@", @"pubsub.", [xmppStream hostName]] resource:nil];
    
    //setup extensions
    
    //PubSub extension : enable publish subscribe XEP-0060 xmpp extension
    xmppPubSub = [[XMPPPubSub alloc] initWithServiceJID: self.service];
    
	// Activate xmpp modules
    [xmppPubSub activate:xmppStream];
    
    //add delegate
    [xmppPubSub addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSString * jid = options.username;
    NSString * password = options.password;
    
    //notify delegate connection
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connecting", @"status",
                                [NSNumber numberWithInt:NO_ERROR], @"code", nil];
    [delegate notifyIncomingMessage:resDict context:@"link"];
    
    
    if(![xmppStream isConnected] && jid != nil && password != nil) {
        [xmppStream setMyJID:[XMPPJID jidWithString:jid]];
        
        NSError * error = nil;
        if (![xmppStream connect:&error]) {
            NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                                                                [NSNumber numberWithInt:CONNECTION_FAILED], @"code", nil];
            [delegate notifyIncomingMessage:errorDict context:@"link"];
            
            NSLog(@"HCXmpp error on connect : %@", error);
        }
        
    }
}

/**
 * see HCTransport protocol
 */
- (void)disconnect {
    //notify delegate connection
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"disconnecting", @"status",
                              [NSNumber numberWithInt:NO_ERROR], @"code", nil];
    [delegate notifyIncomingMessage:resDict context:@"link"];
    //go offline
    [self goOffline];
    [xmppStream disconnect];
}

/**
 * see HCTransport protocol
 */
- (NSString*)subscribeToChannel:(NSString*)channel_identifier {
    return [xmppPubSub subscribeToNode:channel_identifier withOptions:nil];
}

/**
 * see HCTransport protocol
 */
- (NSString*)unsubscribeFromChannel:(NSString*)channel_identifier {
    NSString * msgid = [xmppPubSub unsubscribeFromNode:channel_identifier];
    [msgidChannel setObject:channel_identifier forKey:msgid];
    
    /**** TMP TO REMOVE FOR CLEARING SUBSCRIPTIONS ******/
    //[xmppPubSub removeAllSubscriptionsToNode:channel_identifier];
    
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
    
    return [xmppPubSub publishToNode:channel_identifier entry:entry];
}

/**
 * see HCTransport protocol
 */
- (NSString *)getMessagesFromChannel:(NSString *)channel_identifier {
    return [xmppPubSub allItemsForNode:channel_identifier];
}

/******************************************************************************************************************/
#pragma mark - XMPPStream Delegate
/******************************************************************************************************************/

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket 
{
    NSLog(@"XMPP Transport : socket did connect \n");
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    //set security options to connect
    if (options.gateway.xmpp.allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (options.gateway.xmpp.allowSelfSignedCertificates)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
    
    //NSLog(@"XMPP Transport : Will secure -> setting : %@ \n", settings);
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    NSLog(@"XMPP Transport : did secure \n");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	NSLog(@"XMPP Transport : stream did connect \n");
	
    isXmppConnected = YES;
	
    //authenticate once connected
	NSError *error = nil;
    
	if (![[self xmppStream] authenticateWithPassword:options.password error:&error])
	{
        //notify delegate of error
        NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                    [NSNumber numberWithInt:AUTH_FAILED], @"code", nil];
        [delegate notifyIncomingMessage:errorDict context:@"link"];
        
        NSLog(@"HCXmpp error on authentification : %@ \n", error);
	} else {
        //notify delegate connection
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connected", @"status",
                                                                            [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [delegate notifyIncomingMessage:resDict context:@"link"];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP Transport : did authenticate \n");
    isAuthenticated = YES;
    
    //broadcast presence 
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    isAuthenticated = NO;
    
    //notify delegate of error
    NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                [NSNumber numberWithInt:AUTH_FAILED], @"code", nil];
    [delegate notifyIncomingMessage:errorDict context:@"link"];
    
    NSLog(@"HCXmpp error on authentification : %@ \n", error);
    
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	//NSLog(@"XMPP Transport : did receive IQ : %@ \n", iq);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	//NSLog(@"XMPP Transport : did receive message : %@ \n", message);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	//NSLog(@"XMPP Transport : did receive presence : %@ \n", presence);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    //notify delegate of error
    NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"type",
                                [NSNumber numberWithInt:UNKNOWN_ERROR], @"code",
                                @"", @"channel",
                                @"", @"msgid",
                                nil];
    [delegate notifyIncomingMessage:errorDict context:@"error"];
    
	NSLog(@"XMPP Transport : did receive error : %@\n", error);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (error) {
        NSLog(@"XMPP Transport : did disconnect with error : %@ \n", error);
    } else {
        NSLog(@"XMPP Transport : did disconnect \n");
    }
    
    //notify delegate connection
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"disconnected", @"status",
                              [NSNumber numberWithInt:NO_ERROR], @"code", nil];
    [delegate notifyIncomingMessage:resDict context:@"link"];
	
    if (!isXmppConnected) {
        //notify delegate of error
        //NSString * errorDesc = [NSString stringWithFormat:@"Error on connection. Error in domain %@ or route : %@", options.domain, options.route];
        NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                    [NSNumber numberWithInt:CONNECTION_FAILED], @"code", nil];
        [delegate notifyIncomingMessage:errorDict context:@"link"];
        
        NSLog(@"HCXmpp error on connection : %@ \n", error);
    }
    
    isAuthenticated = NO;
    isXmppConnected = NO;
}

/******************************************************************************************************************/
#pragma mark - XMPPPubSub delegate
/******************************************************************************************************************/

- (void)xmppPubSub:(XMPPPubSub *)sender didSubscribe:(XMPPIQ *)iq {
    NSXMLElement * pubsubElem = [iq elementForName:@"pubsub"];
    NSXMLElement * subscriptionElem = [pubsubElem elementForName:@"subscription"];
    
    NSString * channel = [subscriptionElem attributeStringValueForName:@"node"];
    NSString * msgid = [subscriptionElem attributeStringValueForName:@"subid"];
    
    if (!channel) {
        channel = @"";
    }
    
    if (!msgid) {
        channel = @"";
    }
    
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"subscribe", @"type",
                                                                        channel, @"channel",
                                                                        msgid, @"msgid", nil];
    [delegate notifyIncomingMessage:resDict context:@"result"];
    //NSLog(@"HCXmpp pub sub did subscribe : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didUnsubscribe:(XMPPIQ *)iq {
    NSString * msgid = [iq attributeStringValueForName:@"id"];
    
    if (!msgid) {
        msgid = @"";
    }
    
    NSString * channel = [msgidChannel objectForKey:msgid];
    if (!channel) {
        channel = @"";
    } else {
        [msgidChannel removeObjectForKey:msgid];
    }
    
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"unsubscribe", @"type",
                                                                        channel, @"channel",
                              msgid, @"msgid", nil];
    [delegate notifyIncomingMessage:resDict context:@"result"];
    //NSLog(@"HCXmpp pub sub did unsubscribe : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didCreateNode:(NSString *)node withIQ:(XMPPIQ *)iq {
    //NSLog(@"HCXmpp pub sub did create node : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveMessage:(XMPPMessage *)message {
    NSXMLElement * eventElem = [message elementForName:@"event"];
    if (eventElem) {
        NSXMLElement * itemsElem = [eventElem elementForName:@"items"];
        NSString * channel = [itemsElem attributeStringValueForName:@"node"];
        
        if (!channel) {
            channel = nil;
        }
        
        NSArray * items = [itemsElem elementsForName:@"item"];
        
        for (NSXMLElement * item in items) {
            NSString * content = [item stringValue];
            NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel",
                                      content, @"message", nil];
            [delegate notifyIncomingMessage:resDict context:@"message"];
        }
    }
    
    
    //NSLog(@"HCXmpp pub sub did receive message : %@ \n", message);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveError:(XMPPIQ *)iq {
    //notify delegate of error
    NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"type",
                                [NSNumber numberWithInt:UNKNOWN_ERROR], @"code",
                                @"", @"channel",
                                @"", @"msgid",
                                nil];
    [delegate notifyIncomingMessage:errorDict context:@"error"];
    
    NSLog(@"HCXmpp error pub sub : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveResult:(XMPPIQ *)iq {
    //in case we receive items after calling get messages
    NSXMLElement * pubsubElem = [iq elementForName:@"pubsub"];
    if (pubsubElem) {
        NSXMLElement * itemsElem = [pubsubElem elementForName:@"items"];
        
        if (itemsElem) {
            NSString * channel = [itemsElem attributeStringValueForName:@"node"];
            
            if (!channel) {
                channel = nil;
            }
            
            NSArray * items = [itemsElem elementsForName:@"item"];
            
            for (NSXMLElement * item in items) {
                NSString * content = [item stringValue];
                NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel",
                                          content, @"message", nil];
                [delegate notifyIncomingMessage:resDict context:@"message"];
            }
        }
    }
    //NSLog(@"HCXmpp pub sub did receive result : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didPublish:(XMPPIQ *)iq {
    NSXMLElement * pubsubElem = [iq elementForName:@"pubsub"];
    NSXMLElement * publishElem = [pubsubElem elementForName:@"publish"];
    
    NSString * msgid = [iq attributeStringValueForName:@"id"];
    NSString * channel = [publishElem attributeStringValueForName:@"node"];
    
    if (!msgid) {
        msgid = @"";
    }

    if (!channel) {
        channel = @"";
    }
    
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"publish", @"type",
                              channel, @"channel",
                              msgid, @"msgid", nil];
    
    [delegate notifyIncomingMessage:resDict context:@"result"];
    
    //NSLog(@"HCXmpp pub sub did publish : %@ \n", iq);
}

@end
