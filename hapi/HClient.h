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
#import "Transport/HTransport.h"
#import "options/HOptions.h"
#import "HMessage.h"
#import "HErrors.h"



@protocol HClientDelegate <NSObject>
- (void)notifyLinkStatusUpdate:(NSString*)status code:(NSNumber*)code;
- (void)notifyResultWithType:(NSString*)type channel:(NSString*)channel_identifier msgid:(NSString*)msgid;
- (void)notifyMessage:(HMessage*)message FromChannel:(NSString*)channel_identifier;
- (void)notifyErrorOfType:(NSString*)type code:(NSNumber*)code channel:(NSString*)channel_identifier msgid:(NSString*)id;
@end



@interface HClient : NSObject <HTransportDelegate>

@property (strong) id<HClientDelegate> delegate;
@property (strong, nonatomic, readonly) HOptions * options;

+ (id)clientWithUsername:(NSString*)username password:(NSString*)password delegate:(id<HClientDelegate>)delegate options:(HOptions*)options;

+ (id)clientWithUsername:(NSString *)username password:(NSString *)password callbackBlock:( void (^)(NSString * context, NSDictionary * data) )callback options:(HOptions*)options;

- (id)initWithUsername:(NSString*)username password:(NSString*)password delegate:(id<HClientDelegate>)delegate options:(HOptions*)options;

- (id)initWithUsername:(NSString *)username password:(NSString *)password callbackBlock:( void (^)(NSString * context, NSDictionary * data) )callback options:(HOptions*)options;

- (void)connect;
- (void)disconnect;
- (NSString*)subscribeToChannel:(NSString*)channel_identifier;
- (NSString*)unsubscribeFromChannel:(NSString*)channel_identifier;
- (NSString*)publishToChannel:(NSString*)channel_identifier message:(HMessage*)message;
- (NSString*)getMessagesFromChannel:(NSString*)channel_identifier;

@end
