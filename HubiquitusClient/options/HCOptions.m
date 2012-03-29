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

#import "HCOptions.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @internal
 */
@interface HCOptions () {
@private
    HCGatewayOptions * _gateway;
    NSString * _username;
    NSString * _domain;
}
@end

/**
 * Hubiquitus client options.
 */
@implementation HCOptions
@synthesize username = _username, password, route, domain = _domain;
@synthesize gateway = _gateway;

/**
 * convenient consctructor. see : initWithDict:
 */
+ (id)optionsWithDict:(NSDictionary *)dict {
    return [[HCOptions alloc] initWithDict:dict];
}

/**
 * convenient constructor. see : initWithPlist:
 */
+ (id)optionsWithPlist:(NSString *)path {
    return [[HCOptions alloc] initWithPlist:path];
}

/**
 * Create options set for hubiquitus client with dictionnary
 * For more information see https://github.com/hubiquitus/hubiquitusios/wiki/Options
 * @param dict - a dictionnary that contains the options of the client
 *                The dictionnary content may contains or not these values : 
 *                      - NSString route (aka : my_route.com)
 *                      - NSDictionnary gateway : 
 *                              - NSString transport (either socketio or bosh)
 *                              - NSDictionnary socketio : 
 *                                      - NSString endpoint : my_gateway.com
 *                                      - NSArray ports (aka : 8080, 9090...)
 *                                      - NSString namespace (aka : /my_namespace)
 *                              - NSDictionnary xmpp : 
 *                                      - NSString endpoint : my_gatewway.com
 *                                      - NSArray ports (aka : 8080, 9090...)
 */
-(id)initWithDict:(NSDictionary *)dict {
    
    self = [super init]; 
    if (self) {
        //init with default values
        _username = @"";
        password = @"";
        _domain = @"";
        route = @"";
        _gateway = [HCGatewayOptions optionsWithDict:[dict objectForKey:@"gateway"]];

        if (dict != nil && [dict objectForKey:@"route"]) {
            route = [dict objectForKey:@"route"];
        }
        
    }
    
    return self;
}

/**
 * Creation options set for hubiquitus client with plist
 * For more informations see https://github.com/hubiquitus/hubiquitusios/wiki/Options
 */
- (id)initWithPlist:(NSString *)path {
    NSDictionary * options = [NSDictionary dictionaryWithContentsOfFile:path];
    return [self initWithDict:options];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{username : %@, password : *****, domain : %@, route : %@, gateway : %@}", self.username, self.domain, route, _gateway];
}

/**
 * @internal
 * set the username and the domain based on the username
 * @param aUsername - username of the xmpp server (aka : me@my.xmppserver.com)
 */
- (void)setUsername:(NSString *)aUsername {
    _username = aUsername;
    NSArray * components = [aUsername componentsSeparatedByString:@"@"];
    if ([components count] > 1) {
        _domain = [components objectAtIndex:1];
    } else {
        _domain = @"";
    }
}

/**
 * @internal
 * Convinient function. Return the domain part of the route
 * @return - domain part of the route
 */
- (NSString *)routeDomain {
    NSArray * routeComponents = [route componentsSeparatedByString:@":"];
    if ([routeComponents count] > 0) {
        return [routeComponents objectAtIndex:0];
    }
    
    return nil;
}

/**
 * @internal
 * Convinient function. Return the port part of the route
 * @return - port part of the route
 */
- (NSNumber *)routePort {
    NSArray * routeComponents = [route componentsSeparatedByString:@":"];
    if ([routeComponents count] > 1) {
        NSString * portAsString = [routeComponents objectAtIndex:1];
        NSNumber * port = [NSNumber numberWithInt:[portAsString intValue]];
        return port;
    }
    
    return nil;
}



@end
