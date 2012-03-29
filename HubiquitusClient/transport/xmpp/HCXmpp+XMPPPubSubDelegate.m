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

#import "HCXmpp+XMPPPubSubDelegate.h"
#import "HCErrors.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HCXmpp (XMPPPubSubDelegate)

- (void)xmppPubSub:(XMPPPubSub *)sender didSubscribe:(XMPPIQ *)iq {
    NSString * msgid = [iq attributeStringValueForName:@"id"];
    if (![self callBlockForMsgid:msgid withIq:iq]) {
        NSXMLElement * pubsubElem = [iq elementForName:@"pubsub"];
        NSXMLElement * subscriptionElem = [pubsubElem elementForName:@"subscription"];
        
        NSString * channel = [subscriptionElem attributeStringValueForName:@"node"];
        NSString * msgid = [subscriptionElem attributeStringValueForName:@"subid"];
        
        if (!channel) {
            channel = @"";
        }
        
        if (!msgid) {
            msgid = @"";
        }
        
        [self notifyDelegateSubscribeWithMsgid:msgid toChannel:channel];
        
    }
    
    //NSLog(@"HCXmpp pub sub did subscribe : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didUnsubscribe:(XMPPIQ *)iq {
    NSString * msgid = [iq attributeStringValueForName:@"id"];
    if (![self callBlockForMsgid:msgid withIq:iq]) {
        if (!msgid) {
            msgid = @"";
        }
        [self notifyDelegateUnsubscribeWithMsgid:msgid fromChannel:@""];
    }

    //NSLog(@"HCXmpp pub sub did unsubscribe : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didCreateNode:(NSString *)node withIQ:(XMPPIQ *)iq {
    //NSLog(@"HCXmpp pub sub did create node : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveMessage:(XMPPMessage *)message {
    NSXMLElement * eventElem = [message elementForName:@"event"];
    if (eventElem) {
        NSXMLElement * itemsElem = [eventElem elementForName:@"items"];
        NSString * channel = [itemsElem attributeStringValueForName:@"node"];
        
        if (!channel) {
            channel = nil;
        }
        
        NSArray * items = [itemsElem elementsForName:@"item"];
        
        for (NSXMLElement * item in items) {
            [self notifyDelegateMessagefromChannel:channel content:[item stringValue]];
        }
    }
    
    
    //NSLog(@"HCXmpp pub sub did receive message : %@ \n", message);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveError:(XMPPIQ *)iq {
    //set error default value
    NSString * type = @"";
    NSNumber * code = [NSNumber numberWithInt:UNKNOWN_ERROR];
    NSString * channel = @"";
    NSString * msgid = @"";
    
    //deal with errors
    
    msgid = [iq attributeStringValueForName:@"id"];
    
    //remove callback on msgid if error 
    [self removeResultBlockForMsgid:msgid];
    
    NSXMLElement * pubsub = [iq elementForName:@"pubsub"];
    NSXMLElement * errorElem = [iq elementForName:@"error"];
    
    if (pubsub) {
        NSXMLElement * unsubcribe = [pubsub elementForName:@"unsubscribe"];
        
        if (unsubcribe) {
            type = @"unsubscribe";
            channel = [unsubcribe attributeStringValueForName:@"node"];
            
            if (errorElem) {
                NSXMLElement * notSubscribed = [errorElem elementForName:@"not-subscribed"];
                if (notSubscribed) {
                    code = [NSNumber numberWithInt:NOT_SUBSCRIBED];
                }
            }
        }
    }
    
    
    
    //notify delegate of error
    [self notifyDelegateErrorWithMsgid:msgid fromChannel:channel withCode:code ofType:type];
    
    NSLog(@"HCXmpp error pub sub : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveResult:(XMPPIQ *)iq {
    NSString * msgid = [iq attributeStringValueForName:@"id"];

    //first check if there is a callback in relation to this msgid
    if (![self callBlockForMsgid:msgid withIq:iq]) {
        //in case we receive items after calling get messages
        NSXMLElement * pubsubElem = [iq elementForName:@"pubsub"];
        if (pubsubElem) {
            NSXMLElement * itemsElem = [pubsubElem elementForName:@"items"];
            
            if (itemsElem) {
                NSString * channel = [itemsElem attributeStringValueForName:@"node"];
                
                if (!channel) {
                    channel = nil;
                }
                
                NSArray * items = [itemsElem elementsForName:@"item"];
                
                for (NSXMLElement * item in items) {
                    [self notifyDelegateMessagefromChannel:channel content:[item stringValue]];
                }
            }
        }
        
    }
    
    //NSLog(@"HCXmpp pub sub did receive result : %@ \n", iq);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didPublish:(XMPPIQ *)iq {
    NSXMLElement * pubsubElem = [iq elementForName:@"pubsub"];
    NSXMLElement * publishElem = [pubsubElem elementForName:@"publish"];
    
    NSString * msgid = [iq attributeStringValueForName:@"id"];
    NSString * channel = [publishElem attributeStringValueForName:@"node"];
    
    if (!msgid) {
        msgid = @"";
    }
    
    if (!channel) {
        channel = @"";
    }
    
    [self notifyDelegatePublishWithMsgid:msgid toChannel:channel];
    
    //NSLog(@"HCXmpp pub sub did publish : %@ \n", iq);
}


@end
