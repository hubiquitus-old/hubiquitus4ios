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
 * Requests a subscription to a node to the server
 * The answer of the server is treated by the delegate or block
 * @param nodeName - Name of the node to subscribe
 * @return id - a request id that can be used to check if subscribe was successful (id returned through callback result)
 */
- (NSString*)subscribeToNode:(NSString*)node;

/**
 * Requests to unsubscribe from an node
 * The answer of the server is treated by the delegate or block
 * @param nodeName - Name of the node to unsubscribe
 * @return id - a request id that can be used to check if unsubscribe was successful (id returned through callback result)
 */
- (NSString*)unsubscribeFromNode:(NSString*)node;

/**
 * Requests to publish entries to a node
 * @param node - Node to publish the items
 * @param item - An hubiquitus message
 * @return id - a request id that can be used to check if publish was successful (id returned through callback result)
 */
- (NSString*)publishToNode:(NSString*)node item:(HCMessage*)item;

@end
