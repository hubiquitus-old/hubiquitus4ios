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

#import <Foundation/Foundation.h>
#import "NSDate+ISO8601.h"
#import "ISO8601DateFormatter.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @version 0.4.0
 * Add support to format date as ISO8601 (Json dates)
 */

@implementation NSDate (ISO8601)

/**
 * Representation of the date as ISO8601 date
 */
-(NSString *) toISO8601 {
    ISO8601DateFormatter * iso8601 = [[ISO8601DateFormatter alloc] init];
    iso8601.includeTime = YES;
    return [iso8601 stringFromDate:self];
}

/**
 * NSDate from a ISO8601 date
 */
+(NSDate *) dateFromISO8601:(NSString *) str {
    ISO8601DateFormatter * iso8601 = [[ISO8601DateFormatter alloc] init];
    iso8601.includeTime = YES;
    return [iso8601 dateFromString:str];
}

@end
