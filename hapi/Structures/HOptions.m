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

#import "HOptions.h"

/**
 * @version 0.6.1
 * hAPI options
 */

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HOptions

- (id)init {
    self = [super init];
    if (self) {
        self.transport = @"socketio";
        self.timeout = 15000;
        self.msgTimeout = 30000;
        self.authCB = ^(NSString* login){
            return [NSDictionary dictionaryWithObjectsAndKeys:login, @"login", nil, @"password", nil];
        };
    }
    
    return self;
}

/**
 * transport layer name (by default socketio)
 * Availables : xmpp, socketio
 */
- (NSString *)transport {
    return [self objectForKey:@"transport" withClass:[NSString class]];
}   

- (void)setTransport:(NSString *)transport {
    [self setObject:transport forKey:@"transport"];
}

/**
 * Connection endpoints (ie : http://localhost:8080/)
 * Only for socketio
 */
- (NSArray *)endpoints {
    return [self objectForKey:@"endpoints" withClass:[NSArray class]];
}

- (void)setEndpoints:(NSArray *)endpoints {
    [self setObject:endpoints forKey:@"endpoints"];
}

/**
 * timeout in ms
 */
- (long)timeout {
    NSNumber * timeout = [self objectForKey:@"timeout" withClass:[NSNumber class]];
    if(timeout == nil)
        return 0;
    
    return [timeout longValue];
}

- (void)setTimeout:(long)timeout {
    if(timeout > 0)
        [self setObject:[NSNumber numberWithLong:timeout] forKey:@"timeout"];
    else
        [self setObject:nil forKey:@"timeout"];
}

/**
 * timeout in ms
 */
- (long)msgTimeout {
    NSNumber * timeout = [self objectForKey:@"msgTimeout" withClass:[NSNumber class]];
    if(timeout == nil)
        return 0;
    
    return [timeout longValue];
}

- (void)setMsgTimeout:(long)msgTimeout {
    if(msgTimeout > 0)
        [self setObject:[NSNumber numberWithLong:msgTimeout] forKey:@"msgTimeout"];
    else
        [self setObject:nil forKey:@"msgTimeout"];
}

@end
