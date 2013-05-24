# hOptions
hOptions is one of the arguments passed to the hClient when the method `connect` is being called.

It follows the hOptions reference and some special values for this platform.

## Transport
Transport to connect to the hubiquitus (from Hubiquitus  Reference)

```objective-c
- (NSString *)transport
```

`Default Value: "socketio"`

## Endpoint
Endpoint of the hubiquitus system. Expects an array from which one will be chosen randomly. (from Hubiquitus Reference)

```objective-c
- (NSArray *)endpoints
```

`Default Value: ["http://localhost:5280/http-bind"]`

## Timeout
Time to wait (ms) while connecting to the hNode. If it doesn't respond in that interval an error will be passed to callback.

```objective-c
- (long)timeout
```

`Default Value: 15000`

## msgTimeout
Timeout (ms) value used by the hAPI for all the services except the send() one. If it doesn't respond in that interval an error will be passed to the callback.

```objective-c
- (long)msgTimeout
```

`Default Value: 30000`

## authCb
If you want use an external script for authentification you can add it here. You just need to use the user as attribut and return a user and his password

```objective-c
authCB = ^(NSString* login){
            return [NSDictionary dictionaryWithObjectsAndKeys:login, @"login", password, @"password", nil];
        };
```