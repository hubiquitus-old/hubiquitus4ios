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

#import "NSObject+SBJSon.h"
#import "HObj.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @version 0.5.0
 * Add support of HObj obects to SBJSon
 */

@implementation NSObject (SBJSon)

/**
 * Convenient function to get JSon representation
 */
- (NSString *)JSONRepresentation {
    id objectToConvert = self;
    if ([self conformsToProtocol:@protocol(HObj)] && ((NSObject<HObj>*)self).nativeObj != self) {
        objectToConvert = ((NSObject<HObj>*)self).nativeObj;
    }
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];    
    NSString *json = [writer stringWithObject:objectToConvert];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error is: %@", writer.error);
    return json;
}

/**
 * internally used by SBJson to convert as a jsonObj
 */
- (NSString *)proxyForJson {
    id objectToConvert = self;
    if ([self conformsToProtocol:@protocol(HObj)] && ((NSObject<HObj>*)self).nativeObj != self) {
        objectToConvert = ((NSObject<HObj>*)self).nativeObj;
    }
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];    
    NSString *json = [writer stringWithObject:objectToConvert];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error is: %@", writer.error);
    return json;
}


@end
