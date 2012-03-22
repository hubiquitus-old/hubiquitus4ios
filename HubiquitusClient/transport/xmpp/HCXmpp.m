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
#import "HCXmpp+XMPPUtils.h"

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
 * init
 */
- (id)init {
    self = [super init];
    if (self) {
        resultBlocks = [NSMutableDictionary dictionary];
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
	
    xmppStream.enableBackgroundingOnSocket = options.gateway.xmpp.runInBackground;
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

/**
 * send xmpp presence
 */
- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

/**
 * send xmpp go offline
 */
- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

/**
 * add a callback on a result with a defined msgid
 * @param msgid - msgid with a result
 * @param data - dictionnary of data to call with the block
 * @param block - block to call
 */
- (void)addResultBlockForMsgid:(NSString *)msgid withData:(NSDictionary *)data block:(void (^)(XMPPIQ * iq, NSDictionary * data))block {
    
    if (msgid && block) {
        NSDictionary * blockAndData = [NSDictionary dictionaryWithObjectsAndKeys:block, @"block",
                                       data, @"data", nil];
        [resultBlocks setObject:blockAndData forKey:msgid];
    }
    
    
}

/**
 * remove a result block callback
 * @param msgid - msgid of the result which needed a callback
 */
- (void)removeResultBlockForMsgid:(NSString *)msgid {
    if (msgid) {
        [resultBlocks removeObjectForKey:msgid];
    }
}

/**
 * if msgid is associated with a block, call it
 * @param msgid 
 * @param iq - xmpp iq result for the callback
 */
- (BOOL)callBlockForMsgid:(NSString *)msgid withIq:(XMPPIQ *)iq {
    BOOL didCallABlock = NO;
    if (msgid && resultBlocks.count > 0) {
        NSDictionary * blockAndData = [resultBlocks objectForKey:msgid];
        
        if (blockAndData) {
            void (^block)(XMPPIQ * iq, NSDictionary * data) = [blockAndData objectForKey:@"block"];
            NSDictionary * data = [blockAndData objectForKey:@"data"];
            block(iq, data);
            didCallABlock = YES;
        }
    }
    
    return didCallABlock;
}

#pragma mark - helper functions to call delegate
- (void)notifyDelegateUnsubscribeWithMsgid:(NSString *)msgid fromChannel:(NSString *)channel {
    if ([self.delegate respondsToSelector:@selector(notifyIncomingMessage:context:)]) {
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"unsubscribe", @"type",
                                  channel, @"channel",
                                  msgid, @"msgid", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"result"];
    }
}

- (void)notifyDelegateSubscribeWithMsgid:(NSString *)msgid toChannel:(NSString *)channel {
    if ([self.delegate respondsToSelector:@selector(notifyIncomingMessage:context:)]) {
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"subscribe", @"type",
                                  channel, @"channel",
                                  msgid, @"msgid", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"result"];
    }
}

- (void)notifyDelegateErrorWithMsgid:(NSString *)msgid fromChannel:(NSString *)channel withCode:(NSNumber *)code ofType:(NSString *)type {
    NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:type, @"type",
                                code, @"code",
                                channel, @"channel",
                                msgid, @"msgid",
                                nil];
    [self.delegate notifyIncomingMessage:errorDict context:@"error"];
}

- (void)notifyDelegateMessagefromChannel:(NSString*)channel content:(NSString *)content {
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel",
                              content, @"message", nil];
    [self.delegate notifyIncomingMessage:resDict context:@"message"];
}

- (void)notifyDelegatePublishWithMsgid:(NSString *)msgid toChannel:(NSString *)channel {
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"publish", @"type",
                              channel, @"channel",
                              msgid, @"msgid", nil];
    
    [self.delegate notifyIncomingMessage:resDict context:@"result"];
}

@end
