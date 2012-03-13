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

#import "HCGatewayOptions.h"

/**
 *  @todo - check fields to make sure they are of valid type and valid syntax
 */

/**
 * @internal
 */
@interface HCGatewayOptions () {
@private
    HCSocketIOOptions * _socketio;
    HCXmppOptions * _xmpp;
}
@end

/**
 * @internal
 * define gateways options
 */
@implementation HCGatewayOptions
@synthesize transport;
@synthesize socketio = _socketio;
@synthesize xmpp = _xmpp;

/**
 * @internal
 * convenient constructor see initWithDict:
 */
+ (id)optionsWithDict:(NSDictionary *)dict {
    return [[HCGatewayOptions alloc] initWithDict:dict];
}

/**
 * @internal
 * @param dict - gateways options dictionnary 
 * Should contains something like this :
 *               - NSString transport (either socketio or bosh)
 *               - NSDictionnary socketio : 
 *                      - NSString endpoint : my_gateway.com
 *                      - NSArray ports (aka : 8080, 9090...)
 *                      - NSString namespace (aka : /my_namespace)
 *                - NSDictionnary xmpp : 
 *                      - NSString anoption ...
 */
- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        transport = @"socketio";
        _socketio = [HCSocketIOOptions optionsWithDict:[dict objectForKey:@"socketio"]];
        _xmpp = [HCXmppOptions optionsWithDict:[dict objectForKey:@"xmpp"]];
        
        if (dict != nil && [dict objectForKey:@"transport"]) {
            transport = [dict objectForKey:@"transport"];
        }
    }
    
    return self;
}

/**
 * @internal
 */
- (NSString *)description {
    return [NSString stringWithFormat:@"{transport : %@, socketio : %@, xmpp : %@}", transport, _socketio, _xmpp];
}

@end
