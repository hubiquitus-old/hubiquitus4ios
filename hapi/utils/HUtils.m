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

#import "HUtils.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @internal
 * pick a random object from an array
 */
id pickRandomValue(NSArray * array) {
    if ([array count] > 0) {
        int index = arc4random() % [array count];
        return [array objectAtIndex:index];
    }
    
    return nil;
}

/**
 * @internal
 * category of SocketIOPacket to add a description
 */
@implementation SocketIOPacket (description)

- (NSString *)description {
    return [NSString stringWithFormat:@"type %@, pID %@, ack %@, name %@, data %@, endpoint %@, args %@", self.type, self.pId, self.ack, self.name, self.data, self.endpoint, self.args];
}

@end

/**
 * return the parts of a urn or null if invalid urn (valid urn : urn:domain:username[/resource])
 * key returned are : username, domain, resource
 */
NSDictionary * splitUrn(NSString * urn) {
    NSDictionary * result = nil;
    if(urn != nil) {
        NSString * regexPattern = @"^urn:([a-zA-Z0-9]{1}[a-zA-Z0-9\\-.]+):([a-zA-Z0-9_,=@;!'%/#\\(\\)\\+\\-\\.\\$\\*\\?]+)\\/{1}?(.+$)";
        
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:nil];
        NSArray * matches = [regex matchesInString:urn options:0 range:NSMakeRange(0, [urn length])];

        for (NSTextCheckingResult * match in matches) {

            if(result == nil && match.numberOfRanges >= 3) {
                NSString * username = [urn substringWithRange:[match rangeAtIndex:2]];
                NSString * domain = [urn substringWithRange:[match rangeAtIndex:1]];
                NSString * resource = nil;

                if(match.numberOfRanges >= 4 && [match rangeAtIndex:3].length > 0) {
                    resource = [urn substringWithRange:[match rangeAtIndex:3]];
                }

                result = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username",
                          domain, @"domain",
                          resource, @"resource", nil];
            }
        }
    }
    
    return result;
}

BOOL isUrn(NSString * urn) {
    NSDictionary * splitedUrn = splitUrn(urn);
    if([splitedUrn objectForKey:@"username"] == nil || [splitedUrn objectForKey:@"domain"] == nil)
        return false;
    else 
        return true;
}