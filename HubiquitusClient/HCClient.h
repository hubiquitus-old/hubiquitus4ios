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
#import "transport/HCTransport.h"
#import "options/HCOptions.h"


@protocol HCClientDelegate <NSObject>
- (void)notifyStatusUpdate:(NSString*)status;
- (void)notifyIncomingItem:(id)item;
@end

@interface HCClient : NSObject <HCTransportDelegate>

@property (strong) id<HCClientDelegate> delegate;
@property (strong, nonatomic, readonly) HCOptions * options;

+ (id)clientWithUsername:(NSString*)username password:(NSString*)password options:(HCOptions*)options delegate:(id<HCClientDelegate>)delegate;

+ (id)clientWithUsername:(NSString *)username password:(NSString *)password options:(HCOptions*)options callbackBlock:( void (^)(NSDictionary * content) )callback;

- (id)initWithUsername:(NSString*)username password:(NSString*)password options:(HCOptions*)options delegate:(id<HCClientDelegate>)delegate;

- (id)initWithUsername:(NSString *)username password:(NSString *)password options:(HCOptions*)options callbackBlock:( void (^)(NSDictionary * content) )callback;

- (void)connect;
- (void)disconnect;
- (void)subscribeToNode:(NSString*)node;
- (void)unsubscribeFromNode:(NSString*)node withSubID:(NSString*)subID;
- (void)publishToNode:(NSString*)node items:(NSArray*)items;


@end
