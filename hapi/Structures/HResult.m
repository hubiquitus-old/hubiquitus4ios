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

#import "HResult.h"
#import "HNativeObjectsCategories.h"

/**
 * @version 0.5.0
 * Result of a command execution
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HResult

/**
 * latitude, longitude of the hMessage
 */
- (ResultStatus)status {
    NSNumber * value = [self objectForKey:@"status" withClass:[NSNumber class]];
    return [value intValue];
}

- (void)setStatus:(ResultStatus)status {
    [self setObject:[NSNumber numberWithInt:status] forKey:@"status"];
}

/**
 * Result of the commande
 */
- (id<HObj>)result {
    return [self objectForKey:@"result" withClass:[NSObject class]];
}

- (void)setResult:(id<HObj>)result {
    [self setObject:result forKey:@"result"];
}

- (NSDictionary*)resultAsDictionary {
    return [self objectForKey:@"result" withClass:[NSDictionary class]];
}

- (void)setResultAsDictionary:(NSDictionary *)resultAsDictionary {
    [self setObject:resultAsDictionary forKey:@"result"];
}

- (NSArray *)resultAsArray {
    return [self objectForKey:@"result" withClass:[NSArray class]];
}

- (void)setResultAsArray:(NSArray *)resultAsArray {
    [self setObject:resultAsArray forKey:@"result"];
}

- (NSNumber *)resultAsNumber {
    return [self objectForKey:@"result" withClass:[NSNumber class]];
}

- (void)setResultAsNumber:(NSNumber *)resultAsNumber {
    [self setObject:resultAsNumber forKey:@"result"];
}

- (NSString *)resultAsString {
    return [self objectForKey:@"result" withClass:[NSString class]];
}

- (void)setResultAsString:(NSString *)resultAsString {
    [self setObject:resultAsString forKey:@"result"];
}

@end
