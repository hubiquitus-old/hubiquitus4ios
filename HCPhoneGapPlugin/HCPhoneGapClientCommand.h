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
#import <Cordova/CDVPlugin.h>
#import "HCClient.h"
#import <Cordova/JSONKit.h>
#import "HCOptions.h"

@interface HCPhoneGapClientCommand : CDVPlugin

@property (nonatomic, copy) NSString* callbackID;
@property (nonatomic, strong) HCOptions * hcoptions;
@property (nonatomic, strong) HCClient * hcclient;
@property (nonatomic, strong) NSString * jsHCClientCallback;

- (void)defaultOptions:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

//mirror functions of api
- (void)initClient:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)connect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)disconnect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)subscribe:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)unsubscribe:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)publish:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)getMessages:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

#pragma mark - helper function
- (void)callCallbackWithArg:(NSDictionary*)arg;

@end
