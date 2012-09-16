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

#import "HTransportOptions.h"
#import "HUtils.h"

/**
 * @cond internal
 * @version 0.5.0
 * Options used by the transport layers
 */

@interface HTransportOptions () {
    NSString * _jid;
    NSString * _jidDomain;
    NSString * _jidUsername;
    NSString * _jidResource;
}

@end

@implementation HTransportOptions
@synthesize password, jid = _jid;
@synthesize jidDomain = _jidDomain, jidResource = _jidResource, jidUsername = _jidUsername;

/**
 * Randomly choose an endpoint from the endpoints
 */
- (NSURL *)endpoint {
    NSString * randomEndpoint = pickRandomValue(self.endpoints);
    NSURL * endpoint = [NSURL URLWithString:randomEndpoint];
    return endpoint;
}

- (id)initWithOptions:(HOptions *)options {
    self = [super init];
    if(self) {
        self.transport = options.transport;
        self.endpoints = options.endpoints;
    }
    
    return self;
}

- (void)setJid:(NSString *)jid {
    _jid = jid;
    NSDictionary * jidComponents =  splitJid(jid);
    _jidDomain = [jidComponents objectForKey:@"domain"];
    _jidUsername = [jidComponents objectForKey:@"username"];
    _jidResource = [jidComponents objectForKey:@"resource"];
}

@end

/**
 * @endcond
 */