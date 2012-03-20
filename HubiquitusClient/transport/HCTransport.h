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

#import <Foundation/Foundation.h>
#import "HCOptions.h"
#import "HCMessage.h"

/**
 * @internal
 * Set of methods to be implemented to receive messages from the server throught the transport layer
 */
@protocol HCTransportDelegate <NSObject>

- (void)notifyIncomingMessage:(NSDictionary*)data context:(NSString*)context;

@end

/**
 * @internal
 * Set of methods to be implemented to act as a transport layer
 */
@protocol HCTransport <NSObject>

/**
 * @internal
 * @param options - global options containing options for the transport layer
 * @param delegate - transport delegate that deals with the messages received from the server
 */
- (id)initWithOptions:(HCOptions*)options delegate:(id<HCTransportDelegate>)delegate;

/**
 * Asks the transport layer to connect to XMPP, connect to a gateway if needed,
 * sends the client's presence and starts listening for messages
 */
- (void)connect;

/**
 * Asks the transport layer to close the XMPP connection and disconnect from the gateway if needed
 */
- (void)disconnect;

/**
 * Requests a subscription to a channel to the server
 * The answer of the server is treated by the delegate or block
 * @param channel_identifier - Name of the channel to subscribe
 * @return msgid - a message id that can be used to check if subscribe was successful (id returned through callback result)
 */
- (NSString*)subscribeToChannel:(NSString*)channel_identifier;

/**
 * Requests to unsubscribe from an node
 * The answer of the server is treated by the delegate or block
 * @param channel_identifier - Name of the channel to unsubscribe from
 * @return msgid - a message id that can be used to check if unsubscribe was successful (id returned through callback result)
 */
- (NSString*)unsubscribeFromChannel:(NSString*)channel_identifier;

/**
 * Requests to publish entries to a node
 * @param channel_identifier - channel to publish the items
 * @param item - An hubiquitus message
 * @return msgid - a message id that can be used to check if publish was successful (id returned through callback result)
 */
- (NSString*)publishToChannel:(NSString*)channel_identifier message:(HCMessage*)message;

/**
 * Request to get messages stored in the channel history
 * @param channel_identifier - channel were messages are stores
 * @return msgid - a msgid that represents a unique identifier for the message sent
 */
- (NSString*)getMessagesFromChannel:(NSString*)channel_identifier;

@end
