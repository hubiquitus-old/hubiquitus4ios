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

#import "HXmppOptions.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @internal
 */
@implementation HXmppOptions
@synthesize runInBackground;
@synthesize allowSSLHostnameMismatch;
@synthesize allowSelfSignedCertificates;
//@synthesize endpoint, ports;

/**
 * @internal
 * see initWithDict:
 */
+ (id)optionsWithDict:(NSDictionary *)dict {
    return [[HXmppOptions alloc] initWithDict:dict];
}

/**
 * @internal
 * @param dict - xmpp options dictionnary 
 * Should contains something like this :
 *                - NSDictionnary xmpp : 
 *                      - NSString anoption ...
 */
- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        runInBackground = NO;
        allowSSLHostnameMismatch = NO;
        allowSelfSignedCertificates = NO;
        
        if (dict != nil && [dict objectForKey:@"runInBackground"]) {
            NSNumber * runInBackgroundNumber = [dict objectForKey:@"runInBackground"];
            runInBackground = [runInBackgroundNumber boolValue];
        }
        
        if (dict != nil  && [dict objectForKey:@"allowSelfSignedCertificates"]) {
            NSNumber * allowSelfSignedCertificatesNumber = [dict objectForKey:@"allowSelfSignedCertificates"];
            allowSelfSignedCertificates = [allowSelfSignedCertificatesNumber boolValue];
        }
        
        if (dict != nil && [dict objectForKey:@"allowSSLHostnameMismatch"]) {
            NSNumber * allowSSLHostnameMismatchNumber = [dict objectForKey:@"allowSSLHostnameMismatch"];
            allowSSLHostnameMismatch = [allowSSLHostnameMismatchNumber boolValue];
        }
        
     /*   endpoint = @"http://localhost/";
        ports = [NSArray arrayWithObject:[NSNumber numberWithInt:5280]];
        
        if (dict != nil && [dict objectForKey:@"endpoint"]) {
            endpoint = [dict objectForKey:@"endpoint"];
        }
        
        if (dict != nil && [dict objectForKey:@"ports"]) {
            ports = [dict objectForKey:@"ports"];
        }*/
    }
    
    return self;
}

/*- (NSString *)description {
    return [NSString stringWithFormat:@"{endpoint : %@, ports : %@}", endpoint, ports];
}*/

@end
