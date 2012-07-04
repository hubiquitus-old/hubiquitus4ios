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
#import "HTransport.h"
#import "XMPPFramework.h"
#import "XMPPPubSub.h"
#import "HReconnect.h"

@interface HXmpp : NSObject {
    @private
    NSMutableDictionary * resultBlocks; //used to add a block call on a result event. key = msgid -> content = void(^)(XMPPIQ * iq, NSDictionnary * data)
}

//@property (nonatomic, strong) NSMutableDictionary * resultBlocks; 

@property (nonatomic, strong) id<HTransportDelegate> delegate;
@property (nonatomic, strong) HOptions * options;
@property (nonatomic) BOOL autoreconnect;
@property (nonatomic, strong) HReconnect * hcreconnect;

//xmppframework components
@property (nonatomic, strong) XMPPStream * xmppStream;
//@property (nonatomic, strong) XMPPReconnect * xmppReconnect;
@property (nonatomic, strong) XMPPPubSub * xmppPubSub;

//xmpp infos
@property (nonatomic, strong) XMPPJID * service; //should be something like pubsub.myservice.com
@property (nonatomic) BOOL isXmppConnected;
@property (nonatomic) BOOL isAuthenticated;

//Xmpp methods
- (void)setupStream; //link xmpp extensions and setup
- (void)teardownStream; //unlink xmpp extensions
- (void)goOnline; //send presence to xmpp
- (void)goOffline; //send offline to xmpp

//result block 
- (void)addResultBlockForMsgid:(NSString*)msgid withData:(NSDictionary*)data block:(void (^)(XMPPIQ * iq, NSDictionary * data))block; 
- (void)removeResultBlockForMsgid:(NSString*)msgid;
- (BOOL)callBlockForMsgid:(NSString*)msgid withIq:(XMPPIQ*)iq; //call the block associated with the msgid if there is one

//helper function to call delegate notifications
- (void)notifyDelegateUnsubscribeWithMsgid:(NSString*)msgid fromChannel:(NSString*)channel;
- (void)notifyDelegateSubscribeWithMsgid:(NSString*)msgid toChannel:(NSString*)channel;
- (void)notifyDelegateErrorWithMsgid:(NSString*)msgid fromChannel:(NSString*)channel withCode:(NSNumber*)code ofType:(NSString*)type;
- (void)notifyDelegateMessagefromChannel:(NSString*)channel content:(NSString *)content;
- (void)notifyDelegatePublishWithMsgid:(NSString*)msgid toChannel:(NSString*)channel;

@end
