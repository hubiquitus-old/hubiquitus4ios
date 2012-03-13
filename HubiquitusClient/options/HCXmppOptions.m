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

#import "HCXmppOptions.h"

/**
 *  @todo - check fields to make sure they are of valid type and valid syntax
 */

/**
 * @internal
 */
@implementation HCXmppOptions
//@synthesize endpoint, ports;

/**
 * @internal
 * see initWithDict:
 */
+ (id)optionsWithDict:(NSDictionary *)dict {
    return [[HCXmppOptions alloc] initWithDict:dict];
}

/**
 * @internal
 * @param dict - xmpp options dictionnary 
 * Should contains something like this :
 *                - NSDictionnary xmpp : 
 *                      - NSString anoption ...
 */
- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
     /*   endpoint = @"http://localhost/";
        ports = [NSArray arrayWithObject:[NSNumber numberWithInt:5280]];
        
        if (dict != nil && [dict objectForKey:@"endpoint"]) {
            endpoint = [dict objectForKey:@"endpoint"];
        }
        
        if (dict != nil && [dict objectForKey:@"ports"]) {
            ports = [dict objectForKey:@"ports"];
        }*/
    }
    
    return self;
}

/*- (NSString *)description {
    return [NSString stringWithFormat:@"{endpoint : %@, ports : %@}", endpoint, ports];
}*/

@end
