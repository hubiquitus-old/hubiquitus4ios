//
//  WebSocket.h
//
//  Originally created for Zimt by Esad Hajdarevic on 2/14/10.
//  Copyright 2010 OpenResearch Software Development OG. All rights reserved.
//
//  Erich Ocean made the code more generic.
//
//  Tobias Rodäbel implemented support for draft-hixie-thewebsocketprotocol-76.
//
//  Updated by Nadim for Novedia Group - Hubiquitus project[hubiquitus.com]
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@class GCDAsyncSocket;
@class WebSocket;

@protocol WebSocketDelegate<NSObject>
@optional
    - (void)webSocket:(WebSocket*)webSocket didFailWithError:(NSError*)error;
    - (void)webSocketDidOpen:(WebSocket*)webSocket;
    - (void)webSocketDidClose:(WebSocket*)webSocket;
    - (void)webSocket:(WebSocket*)webSocket didReceiveMessage:(NSString*)message;
    - (void)webSocketDidSendMessage:(WebSocket*)webSocket;
    - (void)webSocketDidSecure:(WebSocket*)webSocket;
@end

typedef enum {
    WebSocketStateDisconnected,
    WebSocketStateConnecting,
    WebSocketStateConnected,
} WebSocketState;

@interface WebSocket : NSObject<GCDAsyncSocketDelegate> {
    id<WebSocketDelegate> delegate;
    NSURL *url;
    GCDAsyncSocket *socket;
    WebSocketState state;
    BOOL secure;
    NSString *origin;
    NSData *expectedChallenge;
}

@property(nonatomic, strong) id<WebSocketDelegate> delegate;
@property(nonatomic,readonly) NSURL *url;
@property(nonatomic, strong) NSString *origin;
@property(nonatomic,readonly) WebSocketState state;
@property(nonatomic,readonly) BOOL secure;
@property(nonatomic,strong) NSData *expectedChallenge;

+ (id)webSocketWithURLString:(NSString *)urlString delegate:(id<WebSocketDelegate>)delegate;
- (id)initWithURLString:(NSString *)urlString delegate:(id<WebSocketDelegate>)delegate;

- (void)open;
- (void)close;
- (void)send:(NSString*)message;

// Deprecated:
- (BOOL)connected; // Returns state==WebSocketStateConnected

@end

enum {
    WebSocketErrorConnectionFailed = 1,
    WebSocketErrorHandshakeFailed = 2
};

extern NSString * const WebSocketException;
extern NSString * const WebSocketErrorDomain;
