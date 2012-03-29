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


#import "HCSocketIO+HCReconnectDelegate.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HCSocketIO (HCReconnectDelegate)

#pragma mark - HCReconnect delegate
/**
 * HCReconnect delegate method
 * should answer if we are trying to connect, and no if we want to disconnect
 */
- (BOOL)shouldReconnect {
    return self.autoreconnect;
}

/**
 * HCReconnect delegate method
 * return yes if already connected
 */
- (BOOL)connected {
    return self.connectedToGateway && self.connectedToXmpp;
}

/**
 * Used by HCReconnect to reconnect
 */
- (void)reconnect {
    //first of all connect to the gateway
    if (!self.connectedToGateway) {
        [self establishLink];
    } else if (self.connectedToGateway && !self.connectedToXmpp) {
        if (![self attach]) {
            [self connectedToXmpp];
        }
    }
}

@end
