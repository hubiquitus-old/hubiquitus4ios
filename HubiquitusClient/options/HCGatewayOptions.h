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
#import "HCSocketIOOptions.h"
#import "HCXmppOptions.h"

@interface HCGatewayOptions : NSObject
@property (copy, nonatomic) NSString * transport;
@property (readonly, nonatomic) HCSocketIOOptions * socketio;
@property (readonly, nonatomic) HCXmppOptions * xmpp;

+ (id)optionsWithDict:(NSDictionary*)dict;
- (id)initWithDict:(NSDictionary*)dict;



@end
