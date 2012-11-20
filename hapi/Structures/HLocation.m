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

#import "HLocation.h"

/**
 * @version 0.5.0
 * Location of a hMessage
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HLocation

/**
 * latitude, longitude of the hMessage
 */
- (HGeo*)pos {
    return [self objectForKey:@"pos" withClass:[HGeo class]];
}

- (void)setPos:(HGeo*)pos {
    [self setObject:pos forKey:@"pos"];
}

/**
 * building number
 */
- (NSString*)num {
    return [self objectForKey:@"num" withClass:[NSString class]];
}

- (void)setNum:(NSString*)num {
    [self setObject:num forKey:@"num"];
}

/**
 * way type
 */
- (NSString*)wayType {
    return [self objectForKey:@"wayType" withClass:[NSString class]];
}

- (void)setWayType:(NSString*)wayType {
    [self setObject:wayType forKey:@"wayType"];
}

/**
 * way 
 */
- (NSString*)way {
    return [self objectForKey:@"way" withClass:[NSString class]];
}

- (void)setWay:(NSString*)way {
    [self setObject:way forKey:@"way"];
}

/**
 * complementary adress
 */
- (NSString*)addr {
    return [self objectForKey:@"addr" withClass:[NSString class]];
}

- (void)setAddr:(NSString*)addr {
    [self setObject:addr forKey:@"addr"];
}

/**
 * floor
 */
- (NSString*)floor {
    return [self objectForKey:@"floor" withClass:[NSString class]];
}

- (void)setFloor:(NSString*)floor {
    [self setObject:floor forKey:@"floor"];
}

/**
 * building
 */
- (NSString*)building {
    return [self objectForKey:@"building" withClass:[NSString class]];
}

- (void)setBuilding:(NSString*)building {
    [self setObject:building forKey:@"building"];
}

/**
 * zip
 */
- (NSString*)zip {
    return [self objectForKey:@"zip" withClass:[NSString class]];
}

- (void)setZip:(NSString*)zip {
    [self setObject:zip forKey:@"zip"];
}

/**
 * city
 */
- (NSString*)city {
    return [self objectForKey:@"city" withClass:[NSString class]];
}

- (void)setCity:(NSString*)city {
    [self setObject:city forKey:@"city"];
}

/**
 * country code
 */
- (NSString*)countryCode {
    return [self objectForKey:@"countryCode" withClass:[NSString class]];
}

- (void)setCountryCode:(NSString*)countryCode {
    [self setObject:countryCode forKey:@"countryCode"];
}

@end
