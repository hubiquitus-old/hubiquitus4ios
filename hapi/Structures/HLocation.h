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
#import "HStructure.h"
#import "HGeo.h"

@interface HLocation : HStructure

@property (nonatomic, strong) HGeo * pos;
@property (nonatomic, strong) NSString * num;
@property (nonatomic, strong) NSString * wayType;
@property (nonatomic, strong) NSString * way;
@property (nonatomic, strong) NSString * addr;
@property (nonatomic, strong) NSString * floor;
@property (nonatomic, strong) NSString * building;
@property (nonatomic, strong) NSString * zip;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * countryCode;

@end