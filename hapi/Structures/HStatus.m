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

#import "HStatus.h"

/**
 * @version 0.5.0
 * hStatus - notification on connection status
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HStatus

/**
 * Connection status
 * See status for possible values
 */
- (Status)status {
    NSNumber * statusCode = [self objectForKey:@"status" withClass:[NSNumber class]];
    return [statusCode intValue];
}

- (void)setStatus:(Status)aStatus {
    [self setObject:[NSNumber numberWithInt:aStatus] forKey:@"status"];
}

/**
 * Error code in case of an error .(By default : 0 = NO_ERROR)
 * See ErrorCode for possible values
 */
- (ErrorCode)errorCode {
    NSNumber * code = [self objectForKey:@"errorCode" withClass:[NSNumber class]];
    return [code intValue];
}

- (void)setErrorCode:(ErrorCode)errorCode {
    [self setObject:[NSNumber numberWithInt:errorCode] forKey:@"errorCode"];
}

/**
 * In case of an error, a description on what happened on lower levels.
 * Should only be used for debug purpose
 */
- (NSString *)errorMsg {
    return [self objectForKey:@"errorMsg" withClass:[NSString class]];
}

- (void)setErrorMsg:(NSString *)errorMsg {
    [self setObject:errorMsg forKey:@"errorMsg"];
}

@end
