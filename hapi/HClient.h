/*
 * Copyright (c) Novedia Group 2012.
 *
 *    This file is part of Hubiquitus
 *
 *    Permission is hereby granted, free of charge, to any person obtaining a copy
 *    of this software and associated documentation files (the "Software"), to deal
 *    in the Software without restriction, including without limitation the rights
 *    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 *    of the Software, and to permit persons to whom the Software is furnished to do so,
 *    subject to the following conditions:
 *
 *    The above copyright notice and this permission notice shall be included in all copies
 *    or substantial portions of the Software.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 *    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 *    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 *    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 *    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 *    You should have received a copy of the MIT License along with Hubiquitus.
 *    If not, see <http://opensource.org/licenses/mit-license.php>.
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
@property (nonatomic, strong) NSDictionary * session_filter;
@property (nonatomic, readonly) NSString * fullurn;
@property (nonatomic, readonly) NSString * bareurn;
@property (nonatomic, readonly) NSString * resource;

- (void)connectWithLogin:(NSString*)login password:(NSString*)password options:(HOptions*)options context:(NSDictionary*)context;

- (void)disconnect;

- (void)send:(HMessage*)message withBlock:(void(^)(HMessage*))callback;

- (void)getSubscriptionsWithBlock:(void(^)(HMessage*))callback;

- (void)subscribeToActor:(NSString*)actor withBlock:(void(^)(HMessage*))callback;

- (void)unsubscribeFromActor:(NSString*)actor withBlock:(void(^)(HMessage*))callback;

- (void)setFilter:(NSDictionary*)filter withBlock:(void(^)(HMessage*))callback;

- (void)setFilterWithString:(NSString *)filter withBlock:(void (^)(HMessage *))callback;


- (HMessage*)buildMessageWithActor:(NSString*)actor type:(NSString*)type payload:(id)payload options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;

- (HMessage*)buildCommandWithActor:(NSString*)actor cmd:(NSString*)cmd params:(NSDictionary*)params filter:(NSDictionary*)filter options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;

- (HMessage*)buildResultWithActor:(NSString*)actor ref:(NSString*)ref status:(ResultStatus)status result:(id)result options:(HMessageOptions *)msgOptions didFailWithError:(NSError**)error;

@end
