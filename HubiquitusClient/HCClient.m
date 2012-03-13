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

/**
 * @version 0.2.0
 */

#import "HCClient.h"
#import "transport/socketio/HCSocketIO.h"

/**
 *  @todo add bosh transport layer support
 */

@interface HCClient () {
    void (^_callback)(NSDictionary * content);
    HCOptions * _options;
}
@property (strong, nonatomic) id<HCTransport> transport;
@end

@implementation HCClient
@synthesize delegate;
@synthesize options = _options;
@synthesize transport;

/**
 * Convenient constructor 
 * see initWithUsername:password:options:delegate:
 */
+ (id)clientWithUsername:(NSString*)username password:(NSString*)password options:(HCOptions*)options delegate:(id<HCClientDelegate>)delegate {
    
    return [[HCClient alloc] initWithUsername:username password:password options:options delegate:delegate];
}

/**
 * Convenient constructor 
 * see initWithUsername:password:options:callbackBlock:
 */
+ (id)clientWithUsername:(NSString *)username password:(NSString *)password options:(HCOptions*)options callbackBlock:(void (^)(NSDictionary * content))callback {
    
    return [[HCClient alloc] initWithUsername:username password:password options:options callbackBlock:callback];
}

/**
 * Convenient constructor 
 * @param username - server login (ak: me@xmppServer.com)
 * @param password - user password
 * @param options - client options. For more information see HCOptions
 * @param delegate - delegate to receive callback and items from the server. For more informations on messages received by the delegate visit : https://github.com/hubiquitus/hubiquitusjs/wiki/Callback
 */
- (id)initWithUsername:(NSString*)username password:(NSString*)password options:(HCOptions*)options delegate:(id<HCClientDelegate>)aDelegate {
    
    self = [super init];
    if (self) {
        if (!options) {
            _options = [HCOptions optionsWithDict:nil];
        } else {
            _options = options;
        }
        
        self.options.username = username;
        self.options.password = password;
        self.delegate = aDelegate;
        _callback = nil;
        
        //should be changed when bosh support added
        transport = [[HCSocketIO alloc] initWithOptions:_options delegate:self];
    }
    
    return self;
}

/**
 * Convenient constructor 
 * @param username - server login (ak: me@xmppServer.com)
 * @param password - user password
 * @param options - client options. For more information see HCOptions
 * @param callbackBlock - Block called on message from the server. For more informations on messages received by the delegate visit : https://github.com/hubiquitus/hubiquitusjs/wiki/Callback
 */
- (id)initWithUsername:(NSString *)username password:(NSString *)password options:(HCOptions*)options callbackBlock:(void (^)(NSDictionary * content))callback {
    if (self) {
        if (!options) {
            _options = [HCOptions optionsWithDict:nil];
        } else {
            _options = options;
        }
        
        self.options.username = username;
        self.options.password = password;
        
        _callback = callback;
        self.delegate = nil;
        
        //should be changed when bosh support added
        transport = [[HCSocketIO alloc] initWithOptions:_options delegate:self];
    }
    
    return self;
}

/**
 * Asks the transport layer to connect to XMPP, connect to a gateway if needed,
 * sends the client's presence and starts listening for messages
 */
- (void)connect {
    [transport connect];
}

/**
 * Asks the transport layer to close the XMPP connection and disconnect from the gateway if needed
 */
- (void)disconnect {
    [transport disconnect];
}

/**
 * Requests a subscription to a node to the server
 * The answer of the server is treated by the delegate or block
 * @param nodeName - Name of the node to subscribe
 */
- (void)subscribeToNode:(NSString*)node {
    [transport subscribeToNode:node];
}

/**
 * Requests to unsubscribe from an node
 * The answer of the server is treated by the delegate or block
 * @param nodeName - Name of the node to unsubscribe
 * @param subID - Subscription ID of the node to unsubscribe (needed *only* if multiple subscriptions to the same node)
 */
- (void)unsubscribeFromNode:(NSString*)node withSubID:(NSString*)subID {
    [transport unsubscribeFromNode:node withSubID:subID];
}

/**
 * Requests to publish entries to a node
 * @param nodeName - Node to publish the items
 * @param items - Array of elements to publish in the node
 */
- (void)publishToNode:(NSString*)node items:(NSArray*)items {
    [transport publishToNode:node items:items];
}

#pragma mark - internal - transport delegate 
/**
 * @internal
 * Receive status from the server through the transport layer and notify the client delegate
 * see HCTransportDelegate
 */
- (void)notifyStatusUpdate:(NSString *)status {
    if (_callback != nil) {
        _callback([NSDictionary dictionaryWithObjectsAndKeys:@"status", @"type",
                                                            status, @"data", nil]);
    }
    
    if (delegate != nil && [delegate respondsToSelector:@selector(notifyStatusUpdate:)]) {
        [delegate notifyStatusUpdate:status];
    }
}

/**
 * @internal
 * Receive an item from the server through the transport layer and notify the client delegate
 * see HCTransportDelegate
 */
- (void)notifyIncomingItem:(id)item {
    if (_callback != nil) {
        _callback([NSDictionary dictionaryWithObjectsAndKeys:@"data", @"type",
                                                            item, @"data", nil]);
    }
    
    if (delegate != nil && [delegate respondsToSelector:@selector(notifyIncomingItem:)]) {
        [delegate notifyIncomingItem:item];
    }
    
}
@end
