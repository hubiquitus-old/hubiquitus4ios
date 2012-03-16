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
		// Want xmpp to run in the background?
		// 
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = options.gateway.xmpp.runInBackground;
	}
#endif
	
	// Setup reconnect
	// 
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
    
    //Setup PubSub
    //
    //The XMPPPubSub enable to publish and subscibe to a node
    //xmppPubSub = [[XMPPPubSub alloc] init];
    
    
	// Activate xmpp modules
    
	[xmppReconnect activate:xmppStream];
    //[xmppPubSub activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

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

#pragma mark - transport protocol

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
    
    NSLog(@"HCXmpp pubsub service is : %@", self.service);
    
    //Setup PubSub
    //
    //we need to setup here because we need the domain
    //The XMPPPubSub enable to publish and subscibe to a node
    xmppPubSub = [[XMPPPubSub alloc] initWithServiceJID: self.service];
    
    
	// Activate xmpp modules
    [xmppPubSub activate:xmppStream];
    
    //add delegate
    [xmppPubSub addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSString * jid = options.username;
    NSString * password = options.password;
    
    if(![xmppStream isConnected] && jid != nil && password != nil) {
        [xmppStream setMyJID:[XMPPJID jidWithString:jid]];
        
        NSLog(@"XMPP transport : trying to connect");
        
        NSError * error = nil;
        if (![xmppStream connect:&error]) {
            NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                                                                error.description, @"message", nil];
            [delegate notifyIncomingMessage:errorDict context:@"link"];
            
            NSLog(@"HCXmpp error on connect : %@", error);
        }
        
    }
}

/**
 * see HCTransport protocol
 */
- (void)disconnect {
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
    return [xmppPubSub unsubscribeFromNode:channel_identifier];
}

/**
 * see HCTransport protocol
 */
- (NSString*)publishToChannel:(NSString*)channel_identifier item:(HCMessage*)item {
    return nil;
}

#pragma mark - XMPPStream Delegate

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
    
    NSLog(@"XMPP Transport : Will secure -> setting : %@ \n", settings);
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
	
    NSLog(@"XMPP Transport : trying to authenticate");
	if (![[self xmppStream] authenticateWithPassword:options.password error:&error])
	{
        //notify delegate of error
        NSString * errorDesc = [NSString stringWithFormat:@"Error authenticating. Invalid login : %@", options.username];
        NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                    errorDesc, @"message", nil];
        [delegate notifyIncomingMessage:errorDict context:@"link"];
        
        NSLog(@"HCXmpp error on authentification : %@ \n", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP Transport : did authenticate \n");
    
    isAuthenticated = YES;
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    isAuthenticated = NO;
    
    //notify delegate of error
    NSString * errorDesc = [NSString stringWithFormat:@"Error authenticating. Invalid login : %@", options.username];
    NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                errorDesc, @"message", nil];
    [delegate notifyIncomingMessage:errorDict context:@"link"];
    
    NSLog(@"HCXmpp error on authentification : %@ \n", error);
    
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"XMPP Transport : did receive IQ : %@ \n", iq);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	NSLog(@"XMPP Transport : did receive message : %@ \n", message);
    
	// A simple example of inbound message handling.
    
	/*if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                                message:body 
                                                               delegate:nil 
                                                      cancelButtonTitle:@"Ok" 
                                                      otherButtonTitles:nil];
			[alertView show];
		}
		else
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
	}*/
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	NSLog(@"XMPP Transport : did receive presence : %@ \n", presence);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    //notify delegate of error
    NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"type",
                                [NSNumber numberWithInt:UnknownError], @"code",
                                @"", @"node",
                                nil];
    [delegate notifyIncomingMessage:errorDict context:@"link"];
    
	NSLog(@"XMPP Transport : did receive error : %@\n", error);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	NSLog(@"XMPP Transport : did disconnect with error : %@ \n", error);
	
    if (!isXmppConnected) {
        //notify delegate of error
        NSString * errorDesc = [NSString stringWithFormat:@"Error on connection. Error in domain %@ or route : %@", options.domain, options.route];
        NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                    errorDesc, @"message", nil];
        [delegate notifyIncomingMessage:errorDict context:@"link"];
        
        NSLog(@"HCXmpp error on connection : %@ \n", error);
    }
    
    isAuthenticated = NO;
    isXmppConnected = NO;
}

#pragma mark - XMPPPubSub delegate
- (void)xmppPubSub:(XMPPPubSub *)sender didSubscribe:(XMPPIQ *)iq {
    NSLog(@"HCXmpp pub sub did subscribe : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didCreateNode:(NSString *)node withIQ:(XMPPIQ *)iq {
    NSLog(@"HCXmpp pub sub did create node : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"HCXmpp pub sub did receive message : %@ \n", message);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveError:(XMPPIQ *)iq {
    NSLog(@"HCXmpp error pub sub : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveResult:(XMPPIQ *)iq {
    NSLog(@"HCXmpp pub sub did receive result : %@ \n", iq);
}


@end
