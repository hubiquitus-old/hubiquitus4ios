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
#import "status.h"
#import "ErrorCode.h"
#import "Priority.h"
#import "HLocation.h"
#import "HObj.h"
#import "HCommand.h"
#import "HResult.h"
#import "HAck.h"
#import "HConvState.h"
#import "HMeasure.h"
#import "HAlert.h"

@interface HMessage : HStructure

@property (nonatomic, strong) NSString * msgid;
@property (nonatomic, strong) NSString * actor;
@property (nonatomic, strong) NSString * convid;
@property (nonatomic, strong) NSString * ref;
@property (nonatomic, strong) NSString * type;
@property (nonatomic) Priority priority;
@property (nonatomic, strong) NSDate * relevance;
@property (nonatomic) BOOL persistent;
@property (nonatomic, strong) HLocation * location;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * publisher;
@property (nonatomic, strong) NSDate * published;
@property (nonatomic, strong) NSDictionary * headers;

@property (nonatomic, strong) id<HObj> payload;
@property (nonatomic, strong) NSDictionary * payloadAsDictionnary;
@property (nonatomic, strong) NSArray * payloadAsArray;
@property (nonatomic, strong) NSNumber * payloadAsNumber;
@property (nonatomic, strong) NSString * payloadAsString;
@property (nonatomic, strong) HCommand * payloadAsCommand;
@property (nonatomic, strong) HResult * payloadAsResult;
@property (nonatomic, strong) HAck * payloadAsAck;
@property (nonatomic, strong) HConvState * payloadAsConvState;
@property (nonatomic, strong) HMeasure * payloadAsMeasure;
@property (nonatomic, strong) HAlert * payloadAsAlert;

@property (nonatomic) long timeout;
@property (nonatomic, strong) NSDate * sent;

@end
