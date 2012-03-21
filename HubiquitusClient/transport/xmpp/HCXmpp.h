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
#import "HCTransport.h"
#import "XMPPFramework.h"
#import "XMPPPubSub.h"

@interface HCXmpp : NSObject<HCTransport, XMPPStreamDelegate, XMPPPubSubDelegate>

@property (nonatomic, strong) id<HCTransportDelegate> delegate;
@property (nonatomic, strong) HCOptions * options;

@property (nonatomic, strong) XMPPStream * xmppStream;
@property (nonatomic, strong) XMPPReconnect * xmppReconnect;
@property (nonatomic, strong) XMPPPubSub * xmppPubSub;

@property (nonatomic, strong) XMPPJID * service;
@property (nonatomic) BOOL isXmppConnected;
@property (nonatomic) BOOL isAuthenticated;

@property (nonatomic, strong) NSMutableDictionary * msgidChannel; //used to link a msgid and channel request. Needed for did unsubscribe;
@property (nonatomic, strong) NSMutableDictionary * resultBlocks; //used to add a block call on a result event. key = msgid -> content = void(^)(XMPPIQ * iq)
@property (nonatomic, strong) NSMutableDictionary * subscriptionMsgId; //used to link a publish msgid, to the publish msgid returned by the publish function. This is because two times calls, first getsubscriptions and check if already subscribed, the if not subscribed, subscribe

- (void)setupStream;
- (void)teardownStream;

@end
