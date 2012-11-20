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
