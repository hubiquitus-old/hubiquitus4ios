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

#import "HCSocketIO.h"
#import "HCUtils.h"
#import "HCErrors.h"

#import "HCSocketIO+Helper.h"
#import "HCSocketIO+HCReconnectDelegate.h"
#import "HCSocketIO+SocketIODelegate.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * @internal
 * A socketio implementation of the transport layer
 * works only with node.JS https://github.com/hubiquitus/hubiquitus-node
 * see HCTransport protocol for more informations
 */
@implementation HCSocketIO
@synthesize delegate;
@synthesize options;
@synthesize socketio;
@synthesize connectedToGateway;
@synthesize rid;
@synthesize sid;
@synthesize userid;
@synthesize connectedToXmpp;
@synthesize autoreconnect;
@synthesize reconnectPlugin;

/**
 * @internal
 * Connect to the hubiquitus-node gateway
 */
- (void)establishLink {
    socketio = [[SocketIO alloc] initWithDelegate:self];
    
    //pick randomly 
    NSInteger port = [(NSNumber*)pickRandomValue(options.gateway.socketio.ports) integerValue];
    
    //NSLog(@"HCSocketIO Establishing a link to : %@, on port %d, with namespace : %@", options.gateway.socketio.endpoint, port, options.gateway.socketio.namespace);
    
    //connect to host
    [socketio connectToHost:options.gateway.socketio.endpoint onPort:port withParams:nil withNamespace:options.gateway.socketio.namespace];
}

/**
 * @internal
 * Generate a unique message id to send to the server
 * @return - unique message id
 */
- (NSString *)generateMsgid {
	NSString *result = nil;
	
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	if (uuid)
	{
		result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
	}
    
	return result;
}

/**
 * @internal
 * ask the server to attach rather then reconnect to the xmpp server
 * this is quicker
 * @return if a userid is saved, it returns YES, if not NO so we need to reconnect
 */
- (BOOL)attach {
    //try to attach if a userid is set
    if (self.userid && ![self.userid isEqualToString:@""] && !self.connectedToXmpp) {
        //first try to reconnect to the gateway
        [self establishLink];
        
        
        NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.userid, @"userid",
                                     self.sid, @"sid",
                                     [NSString stringWithFormat:@"%d", self.rid], @"rid",
                                     nil];
        
        //start the connection
        [socketio sendEvent:@"attach" withData:parameters];
        
        return YES;
    }

    return NO;
}

/**
 * @internal
 * Ask the server to connect to the xmpp server
 * if a userid is available, we should first try to re attach
 */
- (void)connectToXmpp {
    if (!self.connectedToXmpp) {
        NSString * host = options.domain;
        NSString * port = @"5222"; //default port
        
        //If a route is specified, the host and the port are different than the default
        if (options.route.length > 0) {
            NSArray * routeSlices = [options.route componentsSeparatedByString:@":"];
            host = [routeSlices objectAtIndex:0];
            if (routeSlices.count > 1) {
                port = [routeSlices objectAtIndex:1];
            }
        }
        
        
        NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                     options.username, @"userid",
                                     options.password, @"password",
                                     host, @"host",
                                     port, @"port",
                                     nil];
        
        //start the connection
        //NSLog(@"trying to send connect ");
        [socketio sendEvent:@"hConnect" withData:parameters];
        
        //notify delegate connection
        NSDictionary * notifDict = [NSDictionary dictionaryWithObjectsAndKeys:@"connecting", @"status",
                                    [NSNumber numberWithInt:NO_ERROR], @"code", nil];
        [self.delegate notifyIncomingMessage:notifDict context:@"link"];
    }
}



@end
