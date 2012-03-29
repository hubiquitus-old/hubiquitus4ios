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
#import "transport/socketio/HCSocketIOTransport.h"
#import "transport/xmpp/HCXmppTransport.h"
#import "SBJson.h"

@interface HCClient () {
    void (^_callback)(NSString * context, NSDictionary * data);
    HCOptions * _options;
}
@property (strong, nonatomic) id<HCTransport> transport;

- (HCMessage*)hmessageFromJSonString:(NSString*)jsonMessage;

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
+ (id)clientWithUsername:(NSString *)username password:(NSString *)password callbackBlock:(void (^)(NSString * context, NSDictionary * data))callback options:(HCOptions*)options {
    
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
        
        if ([options.gateway.transport compare:@"xmpp"] == NSOrderedSame) {
            transport = [[HCXmpp alloc] initWithOptions:_options delegate:self];
        } else {
            transport = [[HCSocketIO alloc] initWithOptions:_options delegate:self];
        }
        
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
- (id)initWithUsername:(NSString *)username password:(NSString *)password callbackBlock:(void (^)(NSString * context, NSDictionary * data))callback options:(HCOptions*)options {
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
        
        if ([options.gateway.transport compare:@"socketio"] == NSOrderedSame) {
            transport = [[HCSocketIO alloc] initWithOptions:_options delegate:self];
        } else {
            transport = [[HCXmpp alloc] initWithOptions:_options delegate:self];
        }
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
 * Requests a subscription to a channel to the server
 * The answer of the server is treated by the delegate or block
 * @param channel_identifier - Name of the channel to subscribe
 * @return msgid - a message id that can be used to check if subscribe was successful (id returned through callback result)
 */
- (NSString*)subscribeToChannel:(NSString*)channel_identifier {
    return [transport subscribeToChannel:channel_identifier];
}

/**
 * Requests to unsubscribe from an channel
 * The answer of the server is treated by the delegate or block
 * @param channel_identifier - Name of the channel to unsubscribe from
 * @return msgid - a message id that can be used to check if unsubscribe was successful (id returned through callback result)
 */
- (NSString*)unsubscribeFromChannel:(NSString*)channel_identifier {
    return [transport unsubscribeFromChannel:channel_identifier];
}

/**
 * Requests to publish entries to a channel
 * @param channel_identifer - channel to publish the items
 * @param item - An hubiquitus message to publish
 * @return msgid - a message id that can be used to check if publish was successful (id returned through callback result)
 */
- (NSString*)publishToChannel:(NSString*)channel_identifier message:(HCMessage*)message {
    return [transport publishToChannel:channel_identifier message:message];
}

/**
 * Request to get messages stored in the channel history
 * @param channel_identifier - channel were messages are stores
 * @return msgid - a msgid that represents a unique identifier for the message sent
 */
- (NSString *)getMessagesFromChannel:(NSString *)channel_identifier {
    return [transport getMessagesFromChannel:channel_identifier];
}

#pragma mark - internal - transport delegate 

/**
 * @internal
 * Receive callback message from the server through the transport layer and notify the client delegate
 * see HCTransportDelegate
 */
- (void)notifyIncomingMessage:(NSDictionary*)data context:(NSString *)context {
    if (_callback != nil) {
        
        
        NSDictionary * newData = nil;
        
        //make some pre-transformations
        if ([context isEqualToString:@"message"]) {
            NSString * channel = [data objectForKey:@"channel"];
            NSString * messageAsStr = [data objectForKey:@"message"];
            HCMessage * message = [self hmessageFromJSonString:messageAsStr];
            
            newData = [NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel",
                                                                 message, @"message", nil];
        } else {
            newData = data;
        }
        
        
        _callback(context, newData);
    }
    
    //call the right delegate from the context
    if (delegate != nil) {
        if ([context isEqualToString:@"link"] && [delegate respondsToSelector:@selector(notifyLinkStatusUpdate:code:)]) {
            
            NSString * status = [data objectForKey:@"status"];
            NSNumber * code = [data objectForKey:@"code"];
            [delegate notifyLinkStatusUpdate:status code:code];
            
        } else if ([context isEqualToString:@"result"] && [delegate respondsToSelector:@selector(notifyResultWithType:channel:msgid:)]) {
            
            NSString * type = [data objectForKey:@"type"];
            NSString * channel = [data objectForKey:@"channel"];
            NSString * msgid = [data objectForKey:@"msgid"];
            [delegate notifyResultWithType:type channel:channel msgid:msgid];
    
        } else if ([context isEqualToString:@"message"] && [delegate respondsToSelector:@selector(notifyMessage:FromChannel:)]) {
            NSString * channel = [data objectForKey:@"channel"];
            NSString * messageAsStr = [data objectForKey:@"message"];
            
            HCMessage * message = [self hmessageFromJSonString:messageAsStr];
        
            [delegate notifyMessage:message FromChannel:channel];
            
        } else if ([context isEqualToString:@"error"] && [delegate respondsToSelector:@selector(notifyErrorOfType:code:channel:msgid:)]) {
            
            NSString * type = [data objectForKey:@"type"];
            NSNumber * code = [data objectForKey:@"code"];
            NSString * channel = [data objectForKey:@"channel"];
            NSString * msgid = [data objectForKey:@"msgid"];
            [delegate notifyErrorOfType:type code:code channel:channel msgid:msgid];
        }
    }
}

#pragma mark - internal - internal methods
- (HCMessage *)hmessageFromJSonString:(NSString *)jsonMessage {
    SBJsonParser * jsonParser = [[SBJsonParser alloc] init];
    
    NSDictionary * messageAsDict = [jsonParser objectWithString:jsonMessage];
    HCMessage * message = [[HCMessage alloc] initWithDictionnary:messageAsDict];
    
    return message;
}

@end
