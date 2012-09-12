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
#import "ErrorCode.h"
#import "HTransportOptions.h"

/**
 * @cond internal
 * @version 0.5.0
 * Transport layer. Abstract a transport layer. 
 */

/**
 * Defines the transport layer delegate.
 */
@protocol HTransportLayerDelegate <NSObject>

@required

/**
 * Notify a connexion status update
 */
- (void)statusNotification:(Status)status withErrorCode:(ErrorCode)errorCode errorMsg:(NSString*)errorMsg;

/**
 * Notify an hMessage formated into a json string reprensentation
 */
- (void)messageNotification:(NSString*)message;

@end


/**
 * Protocol used by all transports
 */
@protocol HTransportLayer <NSObject>

@required 
@property (strong) id<HTransportLayerDelegate> delegate;
@property (nonatomic, readonly) Status status;

- (id)initWithDelegate:(id<HTransportLayerDelegate>)delegate;

- (void)connectWithOptions:(HTransportOptions*)options;
- (void)disconnect;

/**
 * sending an hMessage as a string representation
 */
- (void)send:(NSString*)message;

@end


/**
 * @endcond
 */
