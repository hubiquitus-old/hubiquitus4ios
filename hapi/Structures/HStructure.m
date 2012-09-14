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
#import "ISO8601DateFormatter.h"

/**
 * @version 0.5.0
 * Base class for hAPI native structures
 * Implements helper functions
 * All hAPI native structures are implemented as getters and setter on a dictionary (obj)
 * Equal is based on dictionary content comparison
 * Description is based on dictionary description
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface HStructure ()
@property (nonatomic, strong) ISO8601DateFormatter * isoDateFormatter;

@end


@implementation HStructure
@synthesize obj;
@synthesize isoDateFormatter;

- (id)init {
    self = [super init];
    if (self) {
        self.isoDateFormatter = [[ISO8601DateFormatter alloc] init];
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
    id<HObj> object = nil;
    if (self.nativeObj && [self.nativeObj isKindOfClass:[NSDictionary class]] && (object = [self.nativeObj objectForKey:aKey])) {
        if([object.nativeObj isKindOfClass:aClass]) {
            return object;
        } else if([aClass isSubclassOfClass:[NSDate class]] && [object.nativeObj isKindOfClass:[NSString class]]) {
            return [isoDateFormatter dateFromString:object.nativeObj];
        }
    }
    return nil;
}

/**
 * Convenient function to set obj dictionnary key
 */
- (void)setObject:(id<HObj>)object forKey:(id)aKey {
    if(object != nil)
        [self.obj setObject:object.nativeObj forKey:aKey];
    else
        [self.obj removeObjectForKey:aKey];
}

#pragma mark - HObj protocol

- (id)nativeObj {
    return obj;
}

- (void)setNativeObj:(id)aNativeObj {
    if ([aNativeObj isKindOfClass:[NSDictionary class]]) {
        obj = [NSMutableDictionary dictionaryWithDictionary:aNativeObj];
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
