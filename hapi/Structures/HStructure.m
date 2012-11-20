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
 * @version 0.5.0
 * Base class for hAPI structures
 * Implements helper functions
 * All hAPI structures inherits NSMutableDictionary
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface HStructure ()
@property (nonatomic, strong) NSMutableDictionary * container;
@end


@implementation HStructure

- (id)init {
    self = [super init];
    if(self) {
        self.container = [[NSMutableDictionary alloc] init];
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
    if ((object = [self.container objectForKey:aKey])) {
        if([object isKindOfClass:aClass]) {
            return object;
        } else if([aClass isSubclassOfClass:[NSDate class]] && [object isKindOfClass:[NSString class]]) {
            return  [NSDate dateFromISO8601:object];
        }
    }
    return nil;
}

#pragma mark - overrides

- (void)setObject:(id)object forKey:(id)aKey {
    if(object != nil)
        if([object isKindOfClass:[NSDate class]])
            [self.container setObject:[object toISO8601] forKey:aKey];
        else
            [self.container setObject:object forKey:aKey];
        else
            [self.container removeObjectForKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [self.container removeObjectForKey:aKey];
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    self = [super init];
    if(self) {
        self.container = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary {
    self = [super init];
    if(self) {
        self.container = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary];
    }
    
    return self;
}

- (NSUInteger)count {
    return [self.container count];
}

- (id)objectForKey:(id)aKey {
    return [self.container objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return [self.container keyEnumerator];
}

#pragma mark - NSObject protocol

/**
 * description of dictionary content
 */
- (NSString *)description {
    return [self.container description];
}

/**
 * compairs class and dictionary contents
 */
- (BOOL)isEqual:(id)object {
    return [self.container isEqual:object];
}

@end
