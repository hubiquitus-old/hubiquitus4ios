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

#import "HCXmpp+XMPPUtils.h"
#import "XMPP.h"
#import "XMPPPubSub.h"

@implementation HCXmpp (XMPPUtils)

- (void)removeAllSubscriptionsToNode:(NSString *)node withPubsub:(XMPPPubSub *)pubsub {
    NSString * msgid = [pubsub getSubscriptionsForNode:node];
    
    //add a block on this function return
    void(^block)(XMPPIQ * iq) = ^(XMPPIQ * iq) {        
        NSXMLElement * pubsubElem = [iq elementForName:@"pubsub"];
        if (pubsubElem) {
            NSXMLElement * subscriptions = [pubsubElem elementForName:@"subscriptions"];
            
            if (subscriptions) {
                NSArray * subscriptionArray = [subscriptions elementsForName:@"subscription"];
                for (NSXMLElement * subscription in subscriptionArray) {
                    NSString * subid = [subscription attributeStringValueForName:@"subid"];
                    if (subid) {
                        NSLog(@"removing with subid : %@", subid);
                        [pubsub unsubscribeFromNode:node withSubid:subid];
                    }
                }
            }
        }
    };
    if (block && msgid) {
        [self.resultBlocks setObject:block forKey:msgid];
    }
}

- (NSArray*)subscriptionsFromResultIQ:(XMPPIQ*)result {
    NSMutableArray * subsArray = [NSMutableArray array];
    NSXMLElement * pubsubElem = [result elementForName:@"pubsub"];
    if (pubsubElem) {
        NSXMLElement * subscriptions = [pubsubElem elementForName:@"subscriptions"];
        
        if (subscriptions) {
            NSString * node = [subscriptions attributeStringValueForName:@"node"];
            NSArray * subscriptionArray = [subscriptions elementsForName:@"subscription"];
            for (NSXMLElement * subscription in subscriptionArray) {
                NSString * subid = [subscription attributeStringValueForName:@"subid"];
                if (subid) {
                    NSDictionary * subDic = [NSDictionary dictionaryWithObjectsAndKeys:node, @"node",
                                                                                        subid, @"subid", nil];
                    [subsArray  addObject:subDic];
                }
            }
        }
    }

    return subsArray;
}

- (BOOL)resultIqHasSubscriptions:(XMPPIQ *)result {
    BOOL hasSubscriptions = NO;

    NSXMLElement * pubsubElem = [result elementForName:@"pubsub"];
    if (pubsubElem) {
        NSXMLElement * subscriptions = [pubsubElem elementForName:@"subscriptions"];
        
        if (subscriptions) {
            NSArray * subscriptionArray = [subscriptions elementsForName:@"subscription"];
            if (subscriptionArray.count > 0) {
                hasSubscriptions = YES;
            }
        }
    }
    
    return hasSubscriptions;
}

@end
