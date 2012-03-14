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
 *  @todo add xmpp transport layer support
 */

@interface HCClient () {
    void (^_callback)(NSString * context, NSArray * data);
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
 * see initWithUsername:password:delegate:options:
 */
+ (id)clientWithUsername:(NSString*)username password:(NSString*)password delegate:(id<HCClientDelegate>)delegate options:(HCOptions*)options {
    
    return [[HCClient alloc] initWithUsername:username password:password delegate:delegate options:options];
}

/**
 * Convenient constructor 
 * see initWithUsername:password:callbackBlock:options:
 */
+ (id)clientWithUsername:(NSString *)username password:(NSString *)password callbackBlock:(void (^)(NSString * context, NSArray * data))callback options:(HCOptions*)options {
    
    return [[HCClient alloc] initWithUsername:username password:password callbackBlock:callback options:options];
}

/**
 * Convenient constructor 
 * @param username - server login (ak: me@xmppServer.com)
 * @param password - user password
 * @param options - client options. For more information see HCOptions
 * @param delegate - delegate to receive callback and items from the server. For more informations on messages received by the delegate visit : https://github.com/hubiquitus/hubiquitusjs/wiki/Callback
 */
- (id)initWithUsername:(NSString*)username password:(NSString*)password delegate:(id<HCClientDelegate>)aDelegate options:(HCOptions*)options {
    
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
 * @param callbackBlock - Block called on message from the server. For more informations on messages received by the callback visit : https://github.com/hubiquitus/hubiquitusjs/wiki/Callback
 */
- (id)initWithUsername:(NSString *)username password:(NSString *)password callbackBlock:(void (^)(NSString * context, NSArray * data))callback options:(HCOptions*)options {
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
 * @return id - a request id that can be used to check if subscribe was successful (id returned through callback result)
 */
- (NSString*)subscribeToNode:(NSString*)node {
    return [transport subscribeToNode:node];
}

/**
 * Requests to unsubscribe from an node
 * The answer of the server is treated by the delegate or block
 * @param nodeName - Name of the node to unsubscribe
 * @return id - a request id that can be used to check if unsubscribe was successful (id returned through callback result)
 */
- (NSString*)unsubscribeFromNode:(NSString*)node {
    return [transport unsubscribeFromNode:node];
}

/**
 * Requests to publish entries to a node
 * @param nodeName - Node to publish the items
 * @param item - An hubiquitus message to publish
 * @return id - a request id that can be used to check if publish was successful (id returned through callback result)
 */
- (NSString*)publishToNode:(NSString*)node item:(HCMessage*)item {
    return [transport publishToNode:node item:item];
}

#pragma mark - internal - transport delegate 

/**
 * @internal
 * Receive callback message from the server through the transport layer and notify the client delegate
 * see HCTransportDelegate
 */
- (void)notifyIncomingMessage:(NSDictionary*)data context:(NSString *)context {
    if (_callback != nil) {
        _callback(context, [data objectForKey:@"data"]);
    }
    
    //call the right delegate from the context
    if (delegate != nil) {
        if ([context compare:@"link"] == NSOrderedSame && [delegate respondsToSelector:@selector(notifyLinkStatusUpdate:message:)]) {
            
            NSString * status = [data objectForKey:@"status"];
            NSString * message = [data objectForKey:@"message"];
            [delegate notifyLinkStatusUpdate:status message:message];
            
        }/* else if ([context compare:@"result"] == NSOrderedSame && [delegate respondsToSelector:@selector(notifyResultWithType:node:request_id:)]) {
            
            NSString * type = [data objectForKey:@"type"];
            NSString * node = [data objectForKey:@"node"];
            NSString * request_id = [data objectForKey:@"id"];
            [delegate notifyResultWithType:type node:node request_id:request_id];
            
        } else if ([context compare:@"items"] == NSOrderedSame && [delegate respondsToSelector:@selector(notifyItems:FromNode:)]) {
            
            NSArray * items = [data objectForKey:@"entries"];
            NSString * node = [data objectForKey:@"node"];
            [delegate notifyItems:items FromNode:node];
            
        } else if ([context compare:@"error"] == NSOrderedSame && [delegate respondsToSelector:@selector(notifyErrorOfType:code:node:request_id:)]) {
            
            NSString * type = [data objectForKey:@"type"];
            NSNumber * code = [data objectForKey:@"code"];
            NSString * node = [data objectForKey:@"node"];
            NSString * request_id = [data objectForKey:@"id"];
            [delegate notifyErrorOfType:type code:[code intValue] node:node request_id:request_id];
        }*/
    }
}
@end
