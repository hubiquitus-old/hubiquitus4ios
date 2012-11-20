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

#import "HResult.h"

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
- (id)result {
    return [self objectForKey:@"result" withClass:[NSObject class]];
}

- (void)setResult:(id)result {
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
