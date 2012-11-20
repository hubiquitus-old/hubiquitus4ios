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

#import "HOptions.h"

/**
 * @version 0.5.0
 * hAPI options
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HOptions

- (id)init {
    self = [super init];
    if (self) {
        self.transport = @"socketio";
        self.timeout = 30000;
    }
    
    return self;
}

/**
 * transport layer name (by default socketio)
 * Availables : xmpp, socketio
 */
- (NSString *)transport {
    return [self objectForKey:@"transport" withClass:[NSString class]];
}   

- (void)setTransport:(NSString *)transport {
    [self setObject:transport forKey:@"transport"];
}

/**
 * Connection endpoints (ie : http://localhost:8080/)
 * Only for socketio
 */
- (NSArray *)endpoints {
    return [self objectForKey:@"endpoints" withClass:[NSArray class]];
}

- (void)setEndpoints:(NSArray *)endpoints {
    [self setObject:endpoints forKey:@"endpoints"];
}

/**
 * Connection endpoints (ie : http://localhost:8080/)
 * Only for socketio
 */
/**
 * timeout in ms
 */
- (long)timeout {
    NSNumber * timeout = [self objectForKey:@"timeout" withClass:[NSNumber class]];
    if(timeout == nil)
        return 0;
    
    return [timeout longValue];
}

- (void)setTimeout:(long)timeout {
    if(timeout > 0)
        [self setObject:[NSNumber numberWithLong:timeout] forKey:@"timeout"];
    else
        [self setObject:nil forKey:@"timeout"];
}
@end
