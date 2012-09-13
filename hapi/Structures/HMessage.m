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

#import "HMessage.h"
#import "HNativeObjectsCategories.h"

/**
 * @version 0.5.0
 * hMessage
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HMessage

/**
 * msgid
 * half filed by hAPI, half by hNode
 */
- (NSString*)msgid {
    return [self objectForKey:@"msgid" withClass:[NSString class]];
}

- (void)setMsgid:(NSString*)msgid {
    [self setObject:msgid forKey:@"msgid"];
}

/**
 * actor
 * Should be a jid
 */
- (NSString*)actor {
    return [self objectForKey:@"actor" withClass:[NSString class]];
}

- (void)setActor:(NSString*)actor {
    [self setObject:actor forKey:@"actor"];
}

/**
 * convid
 */
- (NSString*)convid {
    return [self objectForKey:@"convid" withClass:[NSString class]];
}

- (void)setConvid:(NSString*)convid {
    [self setObject:convid forKey:@"convid"];
}

/**
 * reference a message jid
 */
- (NSString*)ref {
    return [self objectForKey:@"ref" withClass:[NSString class]];
}

- (void)setRef:(NSString*)ref {
    [self setObject:ref forKey:@"ref"];
}

/**
 * type of the payload
 */
- (NSString*)type {
    return [self objectForKey:@"type" withClass:[NSString class]];
}

- (void)setType:(NSString*)type {
    [self setObject:type forKey:@"type"];
}

/**
 * Priority level
 */
- (Priority)priority {
    NSNumber * priority = [self objectForKey:@"priority" withClass:[NSNumber class]];
    return [priority intValue];
}

- (void)setPriority:(Priority)priority {
    [self setObject:[NSNumber numberWithInt:priority] forKey:@"priority"];
}

/**
 * Date until which, the message is relevant
 */
- (NSDate*)relevance {
    return [self objectForKey:@"relevance" withClass:[NSDate class]];
}

- (void)setRelevance:(NSDate*)relevance {
    [self setObject:relevance forKey:@"relevance"];
}

/**
 * Should the message be persisted in a database
 */
- (BOOL)persistent {
    NSNumber * persistent = [self objectForKey:@"persistent" withClass:[NSNumber class]];
    return [persistent boolValue];
}

- (void)setPersistent:(BOOL)persistent {
    [self setObject:[NSNumber numberWithBool:persistent] forKey:@"persistent"];
}

/**
 * Geographical location of the message
 */
- (HLocation*)location {
    return [self objectForKey:@"location" withClass:[HLocation class]];
}

- (void)setLocation:(HLocation*)location {
    [self setObject:location forKey:@"location"];
}

/**
 * author of the message
 */
- (NSString*)author {
    return [self objectForKey:@"author" withClass:[NSString class]];
}

- (void)setAuthor:(NSString*)author {
    [self setObject:author forKey:@"author"];
}

/**
 * Publisher of the message. Should be a jid. Filled by the hAPI
 */
- (NSString*)publisher {
    return [self objectForKey:@"publisher" withClass:[NSString class]];
}

- (void)setPublisher:(NSString*)publisher {
    [self setObject:publisher forKey:@"publisher"];
}

/**
 * Message publication date
 */
- (NSDate*)published {
    return [self objectForKey:@"published" withClass:[NSDate class]];
}

- (void)setPublished:(NSDate*)published {
    [self setObject:published forKey:@"published"];
}

/**
 * Headers
 */
- (NSDictionary*)headers {
    return [self objectForKey:@"headers" withClass:[NSDictionary class]];
}

- (void)setHeaders:(NSDate*)headers {
    [self setObject:headers forKey:@"headers"];
}

/** payload */
 
- (id<HObj>)payload {
    return [self objectForKey:@"payload" withClass:[NSObject class]];
}

- (void)setPayload:(id<HObj>)payload {
    [self setObject:payload forKey:@"payload"];
}

- (NSDictionary*)payloadAsDictionnary {
    return [self objectForKey:@"payload" withClass:[NSDictionary class]];
}

- (void)setPayloadAsDictionnary:(NSDictionary *)payloadAsDictionnary {
    [self setObject:payloadAsDictionnary forKey:@"payload"];
}

- (NSArray *)payloadAsArray {
    return [self objectForKey:@"payload" withClass:[NSArray class]];
}

- (void)setPayloadAsArray:(NSArray *)payloadAsArray {
    [self setObject:payloadAsArray forKey:@"payload"];
}

- (NSNumber *)payloadAsNumber {
    return [self objectForKey:@"payload" withClass:[NSNumber class]];
}

- (void)setPayloadAsNumber:(NSNumber *)payloadAsNumber {
    [self setObject:payloadAsNumber forKey:@"payload"];
}

- (NSString *)payloadAsString {
    return [self objectForKey:@"payload" withClass:[NSString class]];
}

- (void)setPayloadAsString:(NSString *)payloadAsString {
    return [self setObject:payloadAsString forKey:@"payload"];
}

/**
 * timeout in ms
 */
- (long)timeout {
    NSNumber * timeout = [self objectForKey:@"timeout" withClass:[NSNumber class]];
    return [timeout longValue];
}

- (void)setTimeout:(long)timeout {
    [self setObject:[NSNumber numberWithLong:timeout] forKey:@"timeout"];
}
@end
