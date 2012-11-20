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

#import <Foundation/Foundation.h>
#import "NSDate+ISO8601.h"
#import "SBJson.h"
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
