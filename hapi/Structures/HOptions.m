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
#import "NativeObjectsCategories.h"

/**
 * @version 0.4.0
 * hAPI options
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HOptions

- (id)init {
    self = [super init];
    if (self) {
        self.serverPort = 5222;
        self.hServer = @"hnode";
        self.transport = @"socketio";
    }
    
    return self;
}

/**
 * Server host (usually xmpp server)
 */
- (NSString *)serverHost {
    return [self objectForKey:@"serverHost" withClass:[NSString class]];
}

- (void)setServerHost:(NSString *)serverHost {
    [self setObject:serverHost forKey:@"serverHost"];
}

/**
 * Server port (usually xmpp server port. By default 5222);
 */
- (int)serverPort {
    NSNumber * port = [self objectForKey:@"serverPort" withClass:[NSNumber class]];
    return [port intValue];
}

- (void)setServerPort:(int)serverPort {
    [self setObject:[NSNumber numberWithInt:serverPort] forKey:@"serverPort"];
}

/**
 * HServer name (by default : hnode)
 */
- (NSString *)hServer {
    return [self objectForKey:@"hServer" withClass:[NSString class]];
}

- (void)setHServer:(NSString *)hServer {
    [self setObject:hServer forKey:@"hServer"];
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

@end
