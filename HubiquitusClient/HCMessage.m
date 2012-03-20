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

#import "HCMessage.h"

@interface HCMessage () 

@property (strong, nonatomic) NSDictionary * data;

@end

@implementation HCMessage
@synthesize data;

/**
 * Create hubiquitus message from dictionnary
 * @param dict - contains the data of the hubiquitus message
 */
- (id)initWithDictionnary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        data = dict;
    }
 
    return self;
}

/**
 * get the hubiquitus message as a dictionnary
 * @return dictionnary containing the message
 */
- (NSDictionary *)dataToDict {
    return data;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"HCMessage : %@", data];
}
@end
