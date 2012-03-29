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

#import "HCSocketIOOptions.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @internal
 */
@implementation HCSocketIOOptions
@synthesize endpoint, ports, namespace;

/**
 * @internal
 * see initWithDict:
 */
+ (id)optionsWithDict:(NSDictionary *)dict {
    return [[HCSocketIOOptions alloc] initWithDict:dict];
}

/**
 * @internal
 * @param dict - gateways options dictionnary 
 * Should contains something like this :
 *               - NSString endpoint : my_gateway.com
 *               - NSArray ports (aka : 8080, 9090...)
 *               - NSString namespace (aka : /my_namespace)
 */
- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        endpoint = @"http://localhost/";
        ports = [NSArray arrayWithObject:[NSNumber numberWithInt:8080]];
        namespace = @"";
        
        if (dict != nil && [dict objectForKey:@"endpoint"]) {
            endpoint = [dict objectForKey:@"endpoint"];
        }
        
        if (dict != nil && [dict objectForKey:@"ports"]) {
            ports = [dict objectForKey:@"ports"];
        }
        
        if (dict != nil && [dict objectForKey:@"namespace"]) {
            endpoint = [dict objectForKey:@"namespace"];
        }
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{endpoint : %@, ports : %@, namespace : %@}", endpoint, ports, namespace];
}

@end
