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
#import "HCMessage.h"
#import "HCErrors.h"



@protocol HCClientDelegate <NSObject>
- (void)notifyLinkStatusUpdate:(NSString*)status message:(NSString*)message;
- (void)notifyResultWithType:(NSString*)type channel:(NSString*)channel_identifier request_id:(NSString*)request_id;
- (void)notifyItems:(NSArray*)entries FromChannel:(NSString*)channel_identifier;
- (void)notifyErrorOfType:(NSString*)type code:(HCErrors)code channel:(NSString*)channel_identifier request_id:(NSString*)id;
@end



@interface HCClient : NSObject <HCTransportDelegate>

@property (strong) id<HCClientDelegate> delegate;
@property (strong, nonatomic, readonly) HCOptions * options;

+ (id)clientWithUsername:(NSString*)username password:(NSString*)password delegate:(id<HCClientDelegate>)delegate options:(HCOptions*)options;

+ (id)clientWithUsername:(NSString *)username password:(NSString *)password callbackBlock:( void (^)(NSString * context, NSArray * data) )callback options:(HCOptions*)options;

- (id)initWithUsername:(NSString*)username password:(NSString*)password delegate:(id<HCClientDelegate>)delegate options:(HCOptions*)options;

- (id)initWithUsername:(NSString *)username password:(NSString *)password callbackBlock:( void (^)(NSString * context, NSArray * data) )callback options:(HCOptions*)options;

- (void)connect;
- (void)disconnect;
- (NSString*)subscribeToChannel:(NSString*)channel_identifier;
- (NSString*)unsubscribeFromChannel:(NSString*)channel_identifier;
- (NSString*)publishToChannel:(NSString*)channel_identifier item:(HCMessage*)item;


@end
