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
#import "HStructure.h"
#import "status.h"
#import "ErrorCode.h"
#import "Priority.h"
#import "HLocation.h"
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
@property (nonatomic, strong) NSNumber * relevance;
@property (nonatomic) BOOL persistent;
@property (nonatomic, strong) HLocation * location;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * publisher;
@property (nonatomic, strong) NSNumber * published;
@property (nonatomic, strong) NSDictionary * headers;

@property (nonatomic, strong) id payload;
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
@property (nonatomic, strong) NSNumber * sent;

@end
