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
#import "HGatewayOptions.h"

@interface HOptions : NSObject

@property (copy, nonatomic) NSString * username;
@property (copy, nonatomic) NSString * password;
@property (readonly, nonatomic) NSString * domain;
@property (copy, nonatomic) NSString * route;
@property (readonly, nonatomic) NSString * routeDomain;
@property (readonly, nonatomic) NSNumber * routePort;

@property (readonly, nonatomic) HGatewayOptions * gateway;

+ (id)optionsWithDict:(NSDictionary*)dict;
+ (id)optionsWithPlist:(NSString*)path;

- (id)initWithDict:(NSDictionary*)dict;
- (id)initWithPlist:(NSString*)path;


@end
