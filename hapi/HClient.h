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

@interface HClient : NSObject <HTransportDelegate>
@property (nonatomic, readonly) Status status;
@property (nonatomic, strong) void(^onStatus)(HStatus*);
@property (nonatomic, strong) void(^onMessage)(HMessage*);

- (void)connectWithPublisher:(NSString*)publisher password:(NSString*)password options:(HOptions*)options;
- (void)disconnect;

- (void)send:(HMessage*)message withBlock:(void(^)(HMessage*))callback;

@end
