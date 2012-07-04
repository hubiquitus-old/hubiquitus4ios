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

#import "HCPhoneGapClientCommand.h"
#import <Cordova/CDVPluginResult.h>
#import "HCOptions+HCPhoneGapUtil.h"


@implementation HCPhoneGapClientCommand
@synthesize callbackID;
@synthesize hcclient;
@synthesize hcoptions;
@synthesize jsHCClientCallback;


/**
 * return a list of default options to phonegap
 */
- (void)defaultOptions:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    self.callbackID = [arguments pop];
    
    //first init options if needed
    if (!hcoptions) {
        NSString * optionPath = [[NSBundle mainBundle] pathForResource:@"hcoptions" ofType:@"plist"];
        hcoptions = [HCOptions optionsWithPlist:optionPath];
    }
    
    NSString * hcoptionsStr = [hcoptions optionsToJson];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:hcoptionsStr];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackID]];
}

/**
 * create a HubiquitusClient
 */
- (void)initClient:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    //set js callback
    self.jsHCClientCallback = [options objectForKey:@"callback"];
    
    //get args
    NSString * username = [options objectForKey:@"username"];
    NSString * password = [options objectForKey:@"password"];
    NSDictionary * opt = [options objectForKey:@"options"];
    
    //set options
    //first init options if needed
    if (!hcoptions) {
        NSString * optionPath = [[NSBundle mainBundle] pathForResource:@"hcoptions" ofType:@"plist"];
        hcoptions = [HCOptions optionsWithPlist:optionPath];
    }
    [hcoptions optionsFromJson:[opt JSONString]];
    
    //callback function should format hMessage to make as a dict
    hcclient = [HCClient clientWithUsername:username password:password callbackBlock:^(NSString * context, NSDictionary * data) {
        NSDictionary * dataFormated = data;
        if ([context isEqualToString:@"message"]) {
            HCMessage * hMessage = [data objectForKey:@"message"];
            NSDictionary * message = nil;
            NSString * channel = [data objectForKey:@"channel"];
            
            if (!channel) {
                channel = @"";
            }
            
            if (hMessage) {
                message = [hMessage dataToDict];
            } else {
                message = [NSDictionary dictionary];
            }
            
            dataFormated = [NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel", message, @"message", nil];
        }
        
        NSDictionary * msg = [NSDictionary dictionaryWithObjectsAndKeys:context, @"context", dataFormated, @"data", nil];
        [self callCallbackWithArg:msg];
    } options:hcoptions];
}

- (void)connect:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [hcclient connect];
    
}

- (void)disconnect:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [hcclient disconnect];
}

- (void)subscribe:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString * channel = [options objectForKey:@"channel"];
    if (channel) {
        [hcclient subscribeToChannel:channel];
    }
}

- (void)unsubscribe:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString * channel = [options objectForKey:@"channel"];
    if (channel) {
        [hcclient unsubscribeFromChannel:channel];
    }
}

- (void)publish:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString * channel = [options objectForKey:@"channel"];
    NSDictionary * hMessage = [options objectForKey:@"hMessage"];
    if (channel && hMessage && [hMessage isKindOfClass:[NSDictionary class]]) {
        HCMessage * message = [[HCMessage alloc] initWithDictionnary:hMessage];
        [hcclient publishToChannel:channel message:message];
    }
}

- (void)getMessages:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString * channel = [options objectForKey:@"channel"];
    if (channel) {
        [hcclient getMessagesFromChannel:channel];
    }
}

#pragma mark - helper functions
- (void)callCallbackWithArgOnMainThread:(NSDictionary *)arg {
    if (self.jsHCClientCallback) {
        NSString * callbackArg = [arg JSONString];
        NSString * callback = [NSString stringWithFormat:@"var tmpcallback = %@; tmpcallback(%@);", self.jsHCClientCallback, callbackArg];
        [self writeJavascript:callback];
    }
}

- (void)callCallbackWithArg:(NSDictionary*)arg {
    [self performSelectorOnMainThread:@selector(callCallbackWithArgOnMainThread:) withObject:arg waitUntilDone:YES];
}


@end
