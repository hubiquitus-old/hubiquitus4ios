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

#import "HApiPhoneGapPlugin.h"

@implementation HApiPhoneGapPlugin

@synthesize hClient;

- (void)initClient:(CDVInvokedUrlCommand *)command {
    hClient = [[HClient alloc] init];

    __weak HApiPhoneGapPlugin *weakSelf = self;
    hClient.onStatus = ^(HStatus *status) {
        if(status.status == 2){
            NSString * fullUrnString = [NSString stringWithFormat:@"%@ = '%@;'", @"window.plugins.hClient.fullUrn", weakSelf.hClient.fullurn];
            NSString * resourceString = [NSString stringWithFormat:@"%@ = '%@';", @"window.plugins.hClient.resource", weakSelf.hClient.resource];
            NSString * domainString = [NSString stringWithFormat:@"%@ = '%@';", @"window.plugins.hClient.domain", [weakSelf.hClient.fullurn componentsSeparatedByString:@":"][1]];
            [weakSelf.commandDelegate evalJs:fullUrnString];
            [weakSelf.commandDelegate evalJs:resourceString];
            [weakSelf.commandDelegate evalJs:domainString];
        };
        
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:status.status], @"status", [NSNumber numberWithInt:status.errorCode], @"errorCode", nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *hStatus = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString * statusString = [NSString stringWithFormat:@"%@(%@);", @"window.plugins.hClient.onStatus", hStatus];
        [weakSelf.commandDelegate evalJs:statusString];
    };
    
    hClient.onMessage = ^(HMessage *message) {
        NSString *hMessage = [message JSONString];
        
        NSString * messageString = [NSString stringWithFormat:@"%@(%@);", @"window.plugins.hClient.onMessage", hMessage];
        [weakSelf.commandDelegate evalJs:messageString];
    };
}


- (void)connect:(CDVInvokedUrlCommand *)command {
    NSDictionary * args = [command.arguments objectAtIndex:0];
    
    NSString * publisher = [args objectForKey:@"publisher"];
    NSString * password = [args objectForKey:@"password"];
    NSDictionary * connectOptions = [args objectForKey:@"options"];
    
    HOptions *hOptions = [[HOptions alloc] init];
    hOptions.endpoints = [connectOptions objectForKey:@"endpoints"];
    [hClient connectWithLogin:publisher password:password options:hOptions context:nil];
};


- (void)disconnect:(CDVInvokedUrlCommand *)command {
    [hClient disconnect];
}


- (void)send:(CDVInvokedUrlCommand *)command {
    __weak HApiPhoneGapPlugin *weakSelf = self;
    NSDictionary * args = [command.arguments objectAtIndex:0];
    NSString * jsCb = [args objectForKey:@"callback"];
    HMessage * hMessage =  [[HMessage alloc] initWithDictionary:[args objectForKey:@"hmessage"]];
    
    [hClient send:hMessage withBlock:^(HMessage * response) {
        if (jsCb != nil){
            dispatch_async(dispatch_get_main_queue(), ^() {
                NSString *hMessage = [response JSONString];
                
                NSString * messageString = [NSString stringWithFormat:@"var fn = %@; fn(%@);", jsCb, hMessage];
                NSLog(@"Callback String : %@", messageString);
                [weakSelf.commandDelegate evalJs:messageString];
            });
        }
    }];
}


- (void)subscribe:(CDVInvokedUrlCommand *)command {    
    __weak HApiPhoneGapPlugin *weakSelf = self;
    NSDictionary * args = [command.arguments objectAtIndex:0];
    NSString * jsCb = [args objectForKey:@"callback"];

    [hClient subscribeToActor:[args objectForKey:@"actor"] withBlock:^(HMessage * response) {
        if (jsCb != nil){
            dispatch_async(dispatch_get_main_queue(), ^() {
                NSString *hMessage = [response JSONString];
                
                NSString * messageString = [NSString stringWithFormat:@"var fn = %@; fn(%@);", jsCb, hMessage];
                NSLog(@"Callback String : %@", messageString);
                [weakSelf.commandDelegate evalJs:messageString];
            });
        }
    }];
}


- (void)unsubscribe:(CDVInvokedUrlCommand *)command {
    __weak HApiPhoneGapPlugin *weakSelf = self;
    NSDictionary * args = [command.arguments objectAtIndex:0];
    NSString * jsCb = [args objectForKey:@"callback"];
    
    [hClient unsubscribeFromActor:[args objectForKey:@"actor"] withBlock:^(HMessage * response) {
        if (jsCb != nil){
            dispatch_async(dispatch_get_main_queue(), ^() {
                NSString *hMessage = [response JSONString];
                
                NSString * messageString = [NSString stringWithFormat:@"var fn = %@; fn(%@);", jsCb, hMessage];
                NSLog(@"Callback String : %@", messageString);
                [weakSelf.commandDelegate evalJs:messageString];
            });
        }
    }];
}


- (void)setFilter:(CDVInvokedUrlCommand *)command {
    __weak HApiPhoneGapPlugin *weakSelf = self;
    NSDictionary * args = [command.arguments objectAtIndex:0];
    NSString * jsCb = [args objectForKey:@"callback"];
    NSLog(@"SETFILTER %@", [args objectForKey:@"filter"]);
    if ([[args objectForKey:@"filter"] isMemberOfClass:[NSString class]]){
        NSLog(@"HHHHEEERRRREEEEE");
    }
    
    [hClient setFilterWithString:[args objectForKey:@"filter"] withBlock:^(HMessage * response) {
        if (jsCb != nil){
            dispatch_async(dispatch_get_main_queue(), ^() {
                NSString *hMessage = [response JSONString];
                
                NSString * messageString = [NSString stringWithFormat:@"var fn = %@; fn(%@);", jsCb, hMessage];
                NSLog(@"Callback String : %@", messageString);
                [weakSelf.commandDelegate evalJs:messageString];
            });
        }
    }];
}


- (void)getSubscriptions:(CDVInvokedUrlCommand*)command {
    __weak HApiPhoneGapPlugin *weakSelf = self;
    NSDictionary * args = [command.arguments objectAtIndex:0];
    NSString * jsCb = [args objectForKey:@"callback"];
    
    [hClient getSubscriptionsWithBlock:^(HMessage * response) {
        if (jsCb != nil){
            dispatch_async(dispatch_get_main_queue(), ^() {
                NSString *hMessage = [response JSONString];
                
                NSString * messageString = [NSString stringWithFormat:@"var fn = %@; fn(%@);", jsCb, hMessage];
                NSLog(@"Callback String : %@", messageString);
                [weakSelf.commandDelegate evalJs:messageString];
            });
        }
    }];
}


@end
