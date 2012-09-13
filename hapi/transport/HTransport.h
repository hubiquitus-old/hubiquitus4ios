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
#import "HTransportLayer.h"
#import "HStatus.h"
//#import "HMessage.h"
#import "HOptions.h"
#import "HTransportOptions.h"

@protocol HTransportDelegate <NSObject>

@required

- (void)statusNotification:(HStatus*)status;
//- (void)messageNotification:(HMessage*)message;

@end


@interface HTransport : NSObject <HTransportLayerDelegate>

@property id<HTransportDelegate> delegate;

@property (nonatomic, readonly) Status status;
@property (nonatomic) int autoConnectDelay;
@property (nonatomic, strong) HTransportOptions * options;

- (id)initWith:(id<HTransportDelegate>)delegate;

- (void)connectWithOptions:(HTransportOptions*)options;
- (void)disconnect;

//- (void)send:(HMessage*)message;

@end
