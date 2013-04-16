#Functions

* Global variable hClient to access all methods.

### Connect
Starts a connection to Hubiquitus. Status will be received in the `onStatus` callback set by the user and real-time hMessages will be received through the `onMessage` callback. Each command executed has its own callback that receives a hMessage with hResult payload.

```objective-c
- (void)connectWithLogin:(NSString*)login password:(NSString*)password options:(HOptions*)options context:(NSDictionary*)context;
```

Where:

* login : login of the publisher
* password : publisher's password
* options : hOptions object as defined in [hOptions](https://github.com/hubiquitus/hubiquitus4js/tree/master/hOptions)
* context : any other attribute needed by the authentication actor (null by default)

`Note : if a user lost his connection, the hAPI will try to reconnect him automatically`

### disconnect
Stop a connection to hNode.

```objective-c
- (void)disconnect;
```

### Subscribe
Subscribes the connected publisher to a channel.

```objective-c
- (void)subscribeToActor:(NSString*)actor withBlock:(void(^)(HMessage*))callback;
```

Where:

* actor : `<String>` urn of the channel to subscribe (urn:localhost:mychannel)
* callback : `<Function(hMessage)>` callback that receives the hMessage with hResult payload from the executed command.

### Unsubscribe
Unsubscribes the connected publisher from a channel.

```objective-c
(void)unsubscribeFromActor:(NSString*)actor withBlock:(void(^)(HMessage*))callback;
```

Where:

* actor : `<String>` urn of the channel to unsubscribe from
* callback : `<Function(hMessage)>` callback that receives the hMessage with hResult payload from the executed command.

### GetSubscriptions
Recovers in the form of a hMessage with hResult payload a list of the channels to which the user is subscribed. hResult's `result` attribute will be an array of strings containing the `urn` of the channels.

```objective-c
- (void)getSubscriptionsWithBlock:(void(^)(HMessage*))callback;
```

Where:

* callback : `<Function(hMessage)>` callback that receives the hMessage with hResult payload from the executed command.

### SetFilter
Sets a filter for the current session. This filter will be applied to received results from commands and real time hMessages, only letting through messages that match the filter. Note that a empty filter ('{}') means no filter

```objective-c
- (void)setFilter:(NSDictionary*)filter withBlock:(void(^)(HMessage*))callback;
```

Where:

* filter : `<hCondition>` A filter structure as defined in the Hubiquitus Reference.
* callback : `<Function(hMessage)>` callback that receives the hMessage with hResult payload from the executed command.

### send
Send a hMessage to an actor.

```objective-c
- (void)send:(HMessage*)message withBlock:(void(^)(HMessage*))callback;
```

Where:

* hMessage : `<hMessage>` complete hMessage to send.
* callback : `<Function(hMessage)>` callback that receives the hMessage with hResult payload from the executed command.

```
note: possibly the user will want to use hClient.buildMessage() to create the message before sending.
```

### buildMessage
Creates a hMessage structure. Can be used with `hClient.send()` to send a well-formed message.

```objective-c
- (HMessage*)buildMessageWithActor:(NSString*)actor type:(NSString*)type payload:(id)payload options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;
```

Where:

* actor : `<String>` urn of the receiver. If not provided an error will be thrown
* type: `<String>` payload type
* payload: `<Object>` the payload to send
* options: `<hMessageOptions>` an object containing the options to override. If not provided they will be left undefined or filled with default values


### buildhMeasure
Creates a hMessage structure with a hMeasure as a payload. Can be used with `hClient.send()` to send a well-formed message.

```objective-c
- (HMessage*)buildMeasureWithActor:(NSString*)actor value:(NSString*)value unit:(NSString*)unit options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;
```

Where:

* actor : `<String>` urn of the receiver. If not provided an error will be thrown
* value: `<String>` value of the measure. If not provided an error will be thrown
* unit: `<String>` value's unit. If not provided an error will be thrown
* options: `<hMessageOptions>` an object containing the options to override of the hMessage. If not provided they will be left undefined or filled with default ones.

### buildhAlert
Creates a hMessage structure with a hAlert as a payload. Can be used with `hClient.send()` to send a well-formed message.

```objective-c
- (HMessage*)buildAlertWithActor:(NSString*)actor alert:(NSString*)alert options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;
```

Where:

* actor : `<String>` urn of the receiver. If not provided an error will be thrown
* alert: `<String>` message of the alert. If not provided an error will be thrown
* options: `<hMessageOptions>` an object containing the options to override of the hMessage. If not provided they will be left undefined or filled with default ones.

### buildhConvState
Creates a hMessage structure with a hConvState as a payload. Can be used with `hClient.send()` to send a well-formed message.

```objective-c
- (HMessage*)buildConvStateWithActor:(NSString*)actor convid:(NSString*)convid status:(NSString*)status option:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;
```

Where:

* actor : `<String>` urn of the receiver. If not provided an error will be thrown
* convid: `<String>` convid of the conversation.If not provided an error will be thrown
* state: `<String>` id of the hMessage to acknowledge.
* options: `<hMessageOptions>` an object containing the options to override of the hMessage. If not provided they will be left undefined or filled with default ones, save convid given by the user.

### buildhAck
Creates a hMessage structure with a hAck as a payload. Can be used with `hClient.send()` to send a well-formed message.

```objective-c
- (HMessage*)buildAckWithActor:(NSString*)actor ref:(NSString*)ref ack:(NSString*)ack options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;
```

Where:

* actor : `<String>` urn of the receiver. If not provided an error will be thrown
* ackid: `<String>` id of the hMessage to acknowledge . If not provided an error will be thrown
* ack: `<String>` 'recv' or 'read' . If not provided an error will be thrown
* options: `<hMessageOptions>` an object containing the options to override of the hMessage. If not provided they will be left undefined or filled with default ones.

### buildCommand
Creates a hMessage structure with a hCommand as a payload. Can be used with `hClient.send()` to send a well-formed message.

```objective-c
- (HMessage*)buildCommandWithActor:(NSString*)actor cmd:(NSString*)cmd params:(NSDictionary*)params filter:(NSDictionary*)filter options:(HMessageOptions*)msgOptions didFailWithError:(NSError**)error;
```

Where:

* actor : `<String>` urn of the receiver. If not provided an error will be thrown
* cmd : `<String>` the name of the hCommand to form (hSetFilter, hSubscribe, hGetThread...)
* params: `<Object>` the params need by the hCommand
* options: `<hMessageOptions>` an object containing the options to override of the hMessage. If not provided they will be left undefined or filled with default ones.

### buildResult: function(actor, ref, status, result, options)
Creates a hMessage structure with a hResult as a payload. Can be used with `hClient.send()` to send a well-formed message.

```objective-c
- (HMessage*)buildResultWithActor:(NSString*)actor ref:(NSString*)ref status:(ResultStatus)status result:(id)result options:(HMessageOptions *)msgOptions didFailWithError:(NSError**)error;
```
Where:

* actor : `<String>` urn of the receiver. If not provided an error will be thrown
* ref : `<String>` the msgid of the message which rise this result
* status: `<String>` result status code (see [Codes ](https://github.com/hubiquitus/hubiquitus4js/tree/master/Codes) for more details)
* result: `<Object>` the result of the command
* options: `<hMessageOptions>` an object containing the options to override of the hMessage. If not provided they will be left undefined or filled with default ones.