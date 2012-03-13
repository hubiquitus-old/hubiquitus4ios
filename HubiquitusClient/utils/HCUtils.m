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

#import "HCUtils.h"

/**
 * @internal
 * pick a random object from an array
 */
id pickRandomValue(NSArray * array) {
    if ([array count] > 0) {
        int index = arc4random() % [array count];
        return [array objectAtIndex:index];
    }
    
    return nil;
}

/**
 * @internal
 * category of SocketIOPacket to add a description
 */
@implementation SocketIOPacket (description)

- (NSString *)description {
    return [NSString stringWithFormat:@"type %@, pID %@, ack %@, name %@, data %@, endpoint %@, args %@", self.type, self.pId, self.ack, self.name, self.data, self.endpoint, self.args];
}

@end