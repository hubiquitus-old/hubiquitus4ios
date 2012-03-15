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

/**
 * @internal
 * An XMPP implementation of the transport layer
 * see HCTransport protocol for more informations
 */
@implementation HCXmpp
@synthesize delegate;
@synthesize options;
@synthesize xmppStream, xmppReconnect;

- (id)init {
    self = [super init];
    if(self) {
        [self setupStream];
    }
    
    return self;
}

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
    
	// Activate xmpp modules
    
	[xmppReconnect activate:xmppStream];
    
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
    
    NSString * jid = options.username;
    NSString * password = options.password;
    
    if([xmppStream isDisconnected] && jid != nil && password != nil) {
        [xmppStream setMyJID:[XMPPJID jidWithString:jid]];
        
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

}

/**
 * see HCTransport protocol
 */
- (NSString*)subscribeToChannel:(NSString*)channel_identifier {
    return nil;
}

/**
 * see HCTransport protocol
 */
- (NSString*)unsubscribeFromChannel:(NSString*)channel_identifier {
    return nil;
}

/**
 * see HCTransport protocol
 */
- (NSString*)publishToChannel:(NSString*)channel_identifier item:(HCMessage*)item {
    return nil;
}

#pragma mark - XMPPStream Delegate


@end
