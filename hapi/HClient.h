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
#import "Status.h"
#import "HStatus.h"
#import "HOptions.h"
#import "HTransport.h"
#import "HMessage.h"
#import "HMessageOptions.h"

@interface HClient : NSObject <HTransportDelegate>
@property (nonatomic, readonly) Status status;
@property (nonatomic, strong) void(^onStatus)(HStatus*);
@property (nonatomic, strong) void(^onMessage)(HMessage*);

- (void)connectWithPublisher:(NSString*)publisher password:(NSString*)password options:(HOptions*)options;
- (void)disconnect;

- (void)send:(HMessage*)message withBlock:(void(^)(HMessage*))callback;

- (void)getSubscriptionsWithBlock:(void(^)(HMessage*))callback;

- (void)subscribeToActor:(NSString*)actor withBlock:(void(^)(HMessage*))callback;

- (void)unscribeFromActor:(NSString*)actor withBlock:(void(^)(HMessage*))callback;

- (void)getLastMessagesFromActor:(NSString*)actor quantity:(NSNumber*)quantity withBlock:(void(^)(HMessage*))callback;

- (void)getThreadFromActor:(NSString*)actor withConvid:(NSString*)convid block:(void(^)(HMessage*))callback;

- (void)getThreadsFromActor:(NSString*)actor withStatus:(NSString*)status block:(void(^)(HMessage*))callback;

- (void)getRelevantMessagesFromActor:(NSString*)actor withBlock:(void(^)(HMessage*))callback;



- (HMessage*)buildMessageWithActor:(NSString*)actor type:(NSString*)type payload:(id)payload options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;

- (HMessage*)buildCommandWithActor:(NSString*)actor cmd:(NSString*)cmd params:(NSDictionary*)params options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;

- (HMessage*)buildResultWithActor:(NSString*)actor ref:(NSString*)ref status:(ResultStatus)status result:(id)result options:(HMessageOptions *)msgOptions didFailWithError:(NSError**)error;

- (HMessage*)buildConvStateWithActor:(NSString*)actor convid:(NSString*)convid status:(NSString*)status option:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;

- (HMessage*)buildAlertWithActor:(NSString*)actor alert:(NSString*)alert options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;

- (HMessage*)buildAckWithActor:(NSString*)actor ref:(NSString*)ref ack:(NSString*)ack options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;

- (HMessage*)buildMeasureWithActor:(NSString*)actor value:(NSString*)value unit:(NSString*)unit options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;

@end
