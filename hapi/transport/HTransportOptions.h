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

@interface HTransportOptions : NSObject

@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * serverDomain;
@property (nonatomic, strong) NSString * resource;
@property (nonatomic, strong) NSString * bareJid;
@property (nonatomic, strong) NSString * fullJid;

@property (nonatomic, strong) NSString * serverHost;
@property (nonatomic) int * serverPort;

@property (nonatomic, strong) NSArray * endpoints;

@property (nonatomic, strong) NSString * hServerName;
@property (nonatomic, strong) NSString * hServerDomain;
@property (nonatomic, strong) NSString * hServerResource;
@property (nonatomic, strong) NSString * hServerBareJid;
@property (nonatomic, strong) NSString * hServerFullJid;


@end
