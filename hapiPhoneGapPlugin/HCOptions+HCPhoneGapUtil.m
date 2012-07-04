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

#import "HCOptions+HCPhoneGapUtil.h"
#import <Cordova/JSONKit.h>

@implementation HCOptions (HCPhoneGapUtil)

- (NSString *)optionsToJson {
    NSDictionary * socketioOpt = [NSDictionary dictionaryWithObjectsAndKeys: self.gateway.socketio.endpoint, @"endpoint",
                                                                            self.gateway.socketio.ports, @"ports",
                                                                            self.gateway.socketio.namespace, @"namespace", nil];
    
    NSDictionary * xmppOpt = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:self.gateway.xmpp.runInBackground], @"runInBackground",
                              [NSNumber numberWithBool:self.gateway.xmpp.allowSSLHostnameMismatch], @"allowSSLHostnameMismatch", [NSNumber numberWithBool:self.gateway.xmpp.allowSelfSignedCertificates], @"allowSelfSignedCertificates", nil];
    
    NSDictionary * gatewayOpt = [NSDictionary dictionaryWithObjectsAndKeys: self.gateway.transport, @"transport",
                                                                            xmppOpt, @"xmpp", 
                                                                            socketioOpt, @"socketio", nil];
    NSDictionary * opt = [NSDictionary dictionaryWithObjectsAndKeys: self.route, @"route", 
                          gatewayOpt, @"gateway", nil];
    
    return [opt JSONString];
}

- (void)optionsFromJson:(NSString *)optionsJson {
    NSDictionary * opt = [optionsJson objectFromJSONString];
    if (opt && [opt isKindOfClass:[NSDictionary class]]) {
        
        NSString * route = [opt objectForKey:@"route"];
        if (route) {
            self.route = route;
        }
        
        NSDictionary * gateway = [opt objectForKey:@"gateway"];
        if (gateway && [gateway isKindOfClass:[NSDictionary class]]) {
            NSString * transport = [gateway objectForKey:@"transport"];
            if (transport) {
                self.gateway.transport = transport;
            }
            
            NSDictionary * xmppOpt = [gateway objectForKey:@"xmpp"];
            NSDictionary * socketioOpt = [gateway objectForKey:@"socketio"];
            
            if (xmppOpt && [xmppOpt isKindOfClass:[NSDictionary class]]) {
                NSNumber * runInBackground = [xmppOpt objectForKey:@"runInBackground"];
                NSNumber * allowSSLHostnameMismatch = [xmppOpt objectForKey:@"allowSSLHostnameMismatch"];
                NSNumber * allowSelfSignedCertificates = [xmppOpt objectForKey:@"allowSelfSignedCertificates"];
                
                if (runInBackground) {
                    self.gateway.xmpp.runInBackground = [runInBackground boolValue];
                }
                
                if (allowSSLHostnameMismatch) {
                    self.gateway.xmpp.allowSSLHostnameMismatch = [allowSSLHostnameMismatch boolValue];
                }
                
                if (allowSelfSignedCertificates) {
                    self.gateway.xmpp.allowSelfSignedCertificates = [allowSelfSignedCertificates boolValue];
                }
            }
            
            if (socketioOpt && [socketioOpt isKindOfClass:[NSDictionary class]]) {
                NSString * endpoint = [socketioOpt objectForKey:@"endpoint"];
                NSString * namespace = [socketioOpt objectForKey:@"namespace"];
                NSArray * ports = [socketioOpt objectForKey:@"ports"];
                
                if (endpoint) {
                    self.gateway.socketio.endpoint = endpoint;
                }
                
                if (namespace) {
                    self.gateway.socketio.namespace = namespace;
                }
                
                if (ports && [ports isKindOfClass:[NSArray class]]) {
                    self.gateway.socketio.ports = ports;
                }
            }
        }
    }
}

@end
