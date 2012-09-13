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
#import "HNativeObjectsCategories.h"

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
- (double)lng {
    NSNumber * value = [self objectForKey:@"lng" withClass:[NSNumber class]];
    return [value intValue];
}

- (void)setLng:(double)lng {
    [self setObject:[NSNumber numberWithInt:lng] forKey:@"lng"];
}

/**
 * latitude
 */
- (double)lat {
    NSNumber * value = [self objectForKey:@"lat" withClass:[NSNumber class]];
    return [value intValue];
}

- (void)setLat:(double)lat {
    [self setObject:[NSNumber numberWithInt:lat] forKey:@"lat"];
}

@end
