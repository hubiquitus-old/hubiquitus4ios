# Hubiquitus4ios
Use a simple API to connect to a Hubiquitus and do Publish Subscribe using the
*Hubiquitus* protocol. It is compatible with your **ios app**.

To communicate with the server it can use
[socket.io](http://socket.io/). To use it, you need
[hubiquitus](https://github.com/hubiquitus/hubiquitus).


## How to Use

(Coming Soon)

### Details
To receive messages in realtime, use `hClient.onMessage`, you can set this function that
receives a message to whatever you like. For more information about available data received
in real time see [Callback](https://github.com/hubiquitus/hubiquitus4ios/tree/master/docs/Callback)

Once connected it is also possible to execute other commands:

```objective-c
[hClient subscribeToActor:self.actor.text withBlock:_cb]; //Channel to subscribe to using current credentials.
[hClient unsubscribeFromActor:self.actor.text withBlock:_cb]; //Channel to unsubscribe.
[hClient send:msg withBlock:^(HMessage* response) callback]; //Sent an hMessage.
[self.hClient disconnect]; //Disconnects from the Server.
```
Note: a list of all available operations is in [Functions](https://github.com/hubiquitus/hubiquitus4js/tree/master/docs/Functions)

### References
You can find relevant information of all the hubiquitus4ios's references in :
* [Data Structure](https://github.com/hubiquitus/hubiquitus4ios/tree/master/docs/DataStructure)
* [Filter](https://github.com/hubiquitus/hubiquitus4ios/tree/master/docs/Filter)
* [Functions](https://github.com/hubiquitus/hubiquitus4ios/tree/master/docs/Functions)
* [Codes](https://github.com/hubiquitus/hubiquitus4ios/tree/master/docs/Codes)
* [Callback](https://github.com/hubiquitus/hubiquitus4ios/tree/master/docs/Callback)
* [Connect Options](https://github.com/hubiquitus/hubiquitus4ios/tree/master/docs/hOptions)
* [hClient class variables](https://github.com/hubiquitus/hubiquitus4ios/tree/master/docs/hClient-class-variables)

## Options
An `hOptions` object can be sent to the connect function as the last argument.

The keys in this object and an explanation for each one of them can be
found in the [hOptions](https://github.com/hubiquitus/hubiquitus4ios/tree/master/docs/hOptions) page.
There are examples of how to create a *hOptions* object in the `examples/` folder.

## License

Copyright (c) Novedia Group 2012.

This file is part of Hubiquitus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

You should have received a copy of the MIT License along with Hubiquitus.
If not, see [MIT licence](http://opensource.org/licenses/mit-license.php).

