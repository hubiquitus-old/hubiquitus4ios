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

#import "hGeo.h"

/**
 * @version 0.5.0
 * hGeo
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HGeo

/**
 * longitude
 */
- (NSNumber*)lng {
    return [self objectForKey:@"lng" withClass:[NSNumber class]];
}

- (void)setLng:(NSNumber*)lng {
    [self setObject:lng forKey:@"lng"];
}

/**
 * latitude
 */
- (NSNumber*)lat {
    return [self objectForKey:@"lat" withClass:[NSNumber class]];
}

- (void)setLat:(NSNumber*)lat {
    [self setObject:lat forKey:@"lat"];
}

@end
