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
        } else if([aClass isSubclassOfClass:[NSNumber class]] && [object isKindOfClass:[NSNumber class]]) {
            return  [NSDate dateFromTimestampMS:object];
        }
    }
    return nil;
}

#pragma mark - overrides

- (void)setObject:(id)object forKey:(id)aKey {
    if(object != nil)
        [self.container setObject:object forKey:aKey];
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
