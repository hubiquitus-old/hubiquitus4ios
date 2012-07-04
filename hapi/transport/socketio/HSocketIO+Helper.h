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


#import "HSocketIO.h"

@class HSocketIO;

@interface HSocketIO (Helper)

//process events to notify delegate
- (void)processEvent:(NSString*)eventName withArg:(NSDictionary*)arg;
- (void)processLinkEventWithArg:(NSDictionary *)arg;
- (void)processResultEventWithArg:(NSDictionary*)arg;
- (void)processMessageEventWithArg:(NSDictionary*)arg;
- (void)processErrorEventWithArg:(NSDictionary*)arg;
- (void)processAttrsEventWithArg:(NSDictionary*)arg;

//helper functions to notify delegate
- (void)notifyDelegateUnsubscribeWithMsgid:(NSString *)msgid fromChannel:(NSString *)channel;
- (void)notifyDelegateSubscribeWithMsgid:(NSString *)msgid toChannel:(NSString *)channel;
- (void)notifyDelegateErrorWithMsgid:(NSString *)msgid fromChannel:(NSString *)channel withCode:(NSNumber *)code ofType:(NSString *)type;
- (void)notifyDelegateMessagefromChannel:(NSString*)channel content:(NSString *)content;
- (void)notifyDelegatePublishWithMsgid:(NSString *)msgid toChannel:(NSString *)channel;

@end
