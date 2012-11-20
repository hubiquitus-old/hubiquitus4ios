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
- (void)messageNotification:(NSDictionary*)message;

/**
 * Notify an error other than connection error
 */
- (void)errorNotification:(ResultStatus)resultStatus errorMsg:(NSString*)errorMsg refMsg:(NSString*)ref;

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
- (void)send:(NSDictionary*)message;

@end


/**
 * @endcond
 */
