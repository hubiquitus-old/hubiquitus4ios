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


#import "HCSocketIO+Helper.h"
#import "HCErrors.h"

@implementation HCSocketIO (Helper)

#pragma mark - helper functions to deal with event received
/**
 * helper function to route the type of event received 
 */
- (void)processEvent:(NSString*)eventName withArg:(NSDictionary*)arg {
    if ([eventName isEqualToString:@"link"]) {
        [self processLinkEventWithArg:arg];
        
    } else if([eventName isEqualToString:@"attrs"]) {
        [self processAttrsEventWithArg:arg];
        
    } else if([eventName isEqualToString:@"hMessage"]) {
        [self processMessageEventWithArg:arg];
        self.rid = self.rid + 1;
        
    } else if([eventName isEqualToString:@"result"]) {
        [self processResultEventWithArg:arg];
        self.rid = self.rid + 1;
        
    } else if([eventName isEqualToString:@"result_error"]) {
        [self processErrorEventWithArg:arg];
        self.rid = self.rid + 1;
    }
}

/**
 * helper function to deal with link events.
 * format message and notifiy delegate
 */
- (void)processLinkEventWithArg:(NSDictionary *)arg {
    NSString * status = [arg objectForKey:@"status"];
    NSString * codeStr = [arg objectForKey:@"code"];
    NSNumber * code = [NSNumber numberWithInt:NO_ERROR];
    
    /* check that var are not empty */
    if (codeStr) {
        code = [NSNumber numberWithInt:[codeStr intValue]];
    }
    
    if (!status) {
        status = @"";
    }
    
    if ([status isEqualToString:@"connected"]) {
        //notify delegate connection
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connected", @"status",
                                    [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
        
        self.connectedToXmpp = YES;
    } else if ([status isEqualToString:@"disconnected"]) {
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"diconnected", @"status",
                                    [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
        
        self.connectedToXmpp = NO;
    } else if([status isEqualToString:@"attached"]) {
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"attached", @"status",
                                    [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
        
        self.connectedToXmpp = YES;
    } else if([status isEqualToString:@"error"]) {
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                    code, @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
        
        if ([code intValue] == FAILED_ATTACH) {
            self.userid = nil;
            self.sid = nil;
            self.rid = 0;
        }
        
        self.connectedToXmpp = NO;
    }
    
}

/**
 * format and notify delegate for result events
 */
- (void)processResultEventWithArg:(NSDictionary*)arg {
    NSString * type = [arg objectForKey:@"type"];
    NSString * channel = [arg objectForKey:@"channel"];
    NSString * msgid = [arg objectForKey:@"msgid"];
    
    if (!type) {
        type = @"";
    }
    
    if (!channel) {
        channel = @"";
    }
    
    if (!msgid) {
        msgid = @"";
    }
    
    if ([type isEqualToString:@"publish"]) {
        [self notifyDelegatePublishWithMsgid:msgid toChannel:channel];
    } else if([type isEqualToString:@"subscribe"]) {
        [self notifyDelegateSubscribeWithMsgid:msgid toChannel:channel];
    } else if([type isEqualToString:@"unsubscribe"]) {
        [self notifyDelegateUnsubscribeWithMsgid:msgid fromChannel:channel];
    }
}

/**
 * format and notify delegate for hMessage events
 */
- (void)processMessageEventWithArg:(NSDictionary*)arg {
    NSString * channel = [arg objectForKey:@"channel"];
    NSObject * message = [arg objectForKey:@"message"];
    
    if (!channel) {
        channel = @"";
    }
    
    if (message && [message isKindOfClass:[NSString class]]) {
        [self notifyDelegateMessagefromChannel:channel content:(NSString*)message];
    }
}

/**
 * format and notify delegate for errors
 */
- (void)processErrorEventWithArg:(NSDictionary*)arg {
    NSString * type = [arg objectForKey:@"type"];
    NSString * codeStr = [arg objectForKey:@"code"];
    NSString * channel = [arg objectForKey:@"channel"];
    NSString * msgid = [arg objectForKey:@"id"];
    
    if (!type) {
        type = @"";
    }
    
    NSNumber * code = [NSNumber numberWithInt:UNKNOWN_ERROR];
    if (codeStr) {
        code = [NSNumber numberWithInt:[codeStr intValue]];
    }
    
    if (!channel) {
        channel = @"";
    }
    
    if (!msgid) {
        msgid = @"";
    }
    
    [self notifyDelegateErrorWithMsgid:msgid fromChannel:channel withCode:code ofType:type];
}

/**
 * deal with attr events to set userid, sid, rid
 */
- (void)processAttrsEventWithArg:(NSDictionary *)arg {
    NSString * attrsUserId = [arg objectForKey:@"userid"];
    NSString * attrsSid = [arg objectForKey:@"sid"];
    int attrsReqId = [[arg objectForKey:@"rid"] intValue];
    
    self.userid = attrsUserId;
    self.sid = attrsSid;
    self.rid = attrsReqId;
}

#pragma mark - helper functions to call delegate

/**
 * helper function notify delegate
 */
- (void)notifyDelegateUnsubscribeWithMsgid:(NSString *)msgid fromChannel:(NSString *)channel {
    if ([self.delegate respondsToSelector:@selector(notifyIncomingMessage:context:)]) {
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"unsubscribe", @"type",
                                  channel, @"channel",
                                  msgid, @"msgid", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"result"];
    }
}

/**
 * helper function notify delegate
 */
- (void)notifyDelegateSubscribeWithMsgid:(NSString *)msgid toChannel:(NSString *)channel {
    if ([self.delegate respondsToSelector:@selector(notifyIncomingMessage:context:)]) {
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"subscribe", @"type",
                                  channel, @"channel",
                                  msgid, @"msgid", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"result"];
    }
}

/**
 * helper function notify delegate
 */
- (void)notifyDelegateErrorWithMsgid:(NSString *)msgid fromChannel:(NSString *)channel withCode:(NSNumber *)code ofType:(NSString *)type {
    NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:type, @"type",
                                code, @"code",
                                channel, @"channel",
                                msgid, @"msgid",
                                nil];
    [self.delegate notifyIncomingMessage:errorDict context:@"error"];
}

/**
 * helper function notify delegate
 */
- (void)notifyDelegateMessagefromChannel:(NSString*)channel content:(NSString *)content {
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel",
                              content, @"message", nil];
    [self.delegate notifyIncomingMessage:resDict context:@"message"];
}

/**
 * helper function notify delegate
 */
- (void)notifyDelegatePublishWithMsgid:(NSString *)msgid toChannel:(NSString *)channel {
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"publish", @"type",
                              channel, @"channel",
                              msgid, @"msgid", nil];
    
    [self.delegate notifyIncomingMessage:resDict context:@"result"];
}


@end
