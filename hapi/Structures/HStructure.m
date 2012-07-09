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

#import "HStructure.h"

/**
 * @version 0.4.0
 * Base class for hAPI native structures
 * Implements convenient functions
 * hAPI native structures are implemented as getters and setter on a dictionary (obj)
 * Equal is based on dictionary content comparaison
 * Description is based on dictionary comparaison
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HStructure
@synthesize obj;

- (id)init {
    self = [super init];
    if (self) {
        obj = [NSMutableDictionary dictionary];
    }
    
    return self;
}

/**
 * calls obj dictionary objectForKey and check if result is of type aClass
 * @param aKey - key of the object to get from the dictionary
 * @param aClass - value Class expected
 */
- (id)objectForKey:(id)aKey withClass:(__unsafe_unretained Class)aClass {
    id object = nil;
    if (self.nativeObj && [self.nativeObj isKindOfClass:[NSDictionary class]] &&
        (object = [self.nativeObj objectForKey:@"aKey"]) && [object isKindOfClass:aClass]) {
        return object;
    }
    return nil;
}

/**
 * Convenient function to set obj dictionnary key
 */
- (void)setObject:(id<HObj>)object forKey:(id)aKey {
    [self.obj setObject:object forKey:aKey];
}

#pragma mark - HObj protocol

- (id)nativeObj {
    return obj;
}

- (void)setNativeObj:(id)aNativeObj {
    if ([aNativeObj isKindOfClass:[NSDictionary class]]) {
        obj = [NSMutableDictionary dictionaryWithDictionary:obj];
    } else {
        obj = [NSMutableDictionary dictionary];
    }
}

#pragma mark - NSObject protocol

/**
 * description of dictionary content
 */
- (NSString *)description {
    return [self.nativeObj description];
}

/**
 * compairs class and dictionary contents
 */
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[HStructure class]]) {
        NSDictionary * dict = object;
        if ([dict isEqualToDictionary:self.nativeObj]) {
            return true;
        }
    }
    return false;
}

@end
