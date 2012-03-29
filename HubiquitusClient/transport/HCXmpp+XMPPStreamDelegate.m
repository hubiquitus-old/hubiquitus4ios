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

#import "HCXmpp+XMPPStreamDelegate.h"
#import "HCReconnect.h"
#import "HCErrors.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HCXmpp (XMPPStreamDelegate)

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket 
{
    //NSLog(@"XMPP Transport : socket did connect \n");
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    //set security options to connect
    if (self.options.gateway.xmpp.allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (self.options.gateway.xmpp.allowSelfSignedCertificates)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
    
    //NSLog(@"XMPP Transport : Will secure -> setting : %@ \n", settings);
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    //NSLog(@"XMPP Transport : did secure \n");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	//NSLog(@"XMPP Transport : stream did connect \n");
	
    self.isXmppConnected = YES;
	
    //authenticate once connected
	NSError *error = nil;
    
	if (![[self xmppStream] authenticateWithPassword:self.options.password error:&error])
	{
        //notify delegate of error
        NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                    [NSNumber numberWithInt:AUTH_FAILED], @"code", nil];
        [self.delegate notifyIncomingMessage:errorDict context:@"link"];
        
        //NSLog(@"HCXmpp error on authentification : %@ \n", error);
	} else {
        //notify delegate connection
        NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connected", @"status",
                                  [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:resDict context:@"link"];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //NSLog(@"XMPP Transport : did authenticate \n");
    self.isAuthenticated = YES;
    
    //broadcast presence 
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    self.isAuthenticated = NO;
    
    //notify delegate of error
    NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                [NSNumber numberWithInt:AUTH_FAILED], @"code", nil];
    [self.delegate notifyIncomingMessage:errorDict context:@"link"];
    
    //NSLog(@"HCXmpp error on authentification : %@ \n", error);
    
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	//NSLog(@"XMPP Transport : did receive IQ : %@ \n", iq);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	//NSLog(@"XMPP Transport : did receive message : %@ \n", message);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	//NSLog(@"XMPP Transport : did receive presence : %@ \n", presence);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    //set error default value
    NSString * type = @"";
    NSNumber * code = [NSNumber numberWithInt:UNKNOWN_ERROR];
    NSString * channel = @"";
    NSString * msgid = @"";
    
    
    //notify delegate of error
    [self notifyDelegateErrorWithMsgid:msgid fromChannel:channel withCode:code ofType:type];
    
	NSLog(@"XMPP Transport : did receive error : %@\n", error);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (error) {
        NSLog(@"XMPP Transport : did disconnect with error : %@ \n", error);
    } else {
        //NSLog(@"XMPP Transport : did disconnect \n");
    }
    
    //notify delegate connection
    NSDictionary * resDict = [NSDictionary dictionaryWithObjectsAndKeys:@"disconnected", @"status",
                              [NSNumber numberWithInt:NO_ERROR], @"code", nil];
    [self.delegate notifyIncomingMessage:resDict context:@"link"];
	
    if (!self.isXmppConnected) {
        //notify delegate of error
        NSDictionary * errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status",
                                    [NSNumber numberWithInt:CONNECTION_FAILED], @"code", nil];
        [self.delegate notifyIncomingMessage:errorDict context:@"link"];
        
        NSLog(@"HCXmpp error on connection : %@ \n", error);
    }
    
    self.isAuthenticated = NO;
    self.isXmppConnected = NO;
    
    [self.hcreconnect fireAutoReconnect];
}


@end
