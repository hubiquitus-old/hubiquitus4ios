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

@protocol HReconnectDelegate <NSObject>


- (BOOL)shouldReconnect;
- (BOOL)connected;
- (void)reconnect;


@end

@interface HReconnect : NSObject

@property (readonly) int attemptDelay; //in seconds
@property (strong) id<HReconnectDelegate> delegate;

- (id)initWithDelegate:(id<HReconnectDelegate>)delegate;
- (id)initWithDelegate:(id<HReconnectDelegate>)delegate attemptDelay:(int)attemptDelay;
- (void)fireAutoReconnect;


@end
