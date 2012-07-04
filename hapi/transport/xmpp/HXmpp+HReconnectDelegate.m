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


#import "HXmpp+HReconnectDelegate.h"
#import "HXmpp+HTransportProtocol.h"
#import "HErrors.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HXmpp (HReconnectDelegate)

#pragma mark - HCReconnect delegate
/**
 * HCReconnect delegate method
 * should answer if we are trying to connect, and no if we want to disconnect
 */
- (BOOL)shouldReconnect {
    return self.autoreconnect;
}

/**
 * HCReconnect delegate method
 * return yes if already connected
 */
- (BOOL)connected {
    return [self.xmppStream isConnected];
}

/**
 * Used by HCReconnect to reconnect
 */
/**
 * Function called to connect or reconnect
 */
- (void)reconnect {
    if (!self.isXmppConnected) {
        //set hostname and host port
        if (self.options.routeDomain != nil) {
            [self.xmppStream setHostName:self.options.routeDomain];
        } else if (self.options.domain != nil) {
            [self.xmppStream setHostName:self.options.domain];
        }
        
        if (self.options.routePort != nil) {
            [self.xmppStream setHostPort:[self.options.routePort intValue]];
        }
        
        self.service = [XMPPJID jidWithUser:nil domain:[NSString stringWithFormat:@"%@%@", @"pubsub.", [self.xmppStream hostName]] resource:nil];
        
        //setup extensions
        
        //PubSub extension : enable publish subscribe XEP-0060 xmpp extension
        self.xmppPubSub = [[XMPPPubSub alloc] initWithServiceJID: self.service];
        
        // Activate xmpp modules
        [self.xmppPubSub activate:self.xmppStream];
        
        //add delegate
        [self.xmppPubSub addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        NSString * jid = self.options.username;
        NSString * password = self.options.password;
        
        //notify delegate connection
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connecting", @"status",
                                  [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"link"];
        
        
        if(![self.xmppStream isConnected] && jid != nil && password != nil) {
            [self.xmppStream setMyJID:[XMPPJID jidWithString:jid]];
            
            NSError * error = nil;
            if (![self.xmppStream connect:&error]) {
                NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                            [NSNumber numberWithInt:CONNECTION_FAILED], @"code", nil];
                [self.delegate notifyIncomingMessage:errorDict context:@"link"];
                
                NSLog(@"HCXmpp error on connect : %@", error);
            }
            
        }
    }
}

@end
