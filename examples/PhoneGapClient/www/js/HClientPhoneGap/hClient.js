/*
 * Copyright (c) Novedia Group 2012.
 *
 *    This file is part of Hubiquitus
 *
 *    Permission is hereby granted, free of charge, to any person obtaining a copy
 *    of this software and associated documentation files (the "Software"), to deal
 *    in the Software without restriction, including without limitation the rights
 *    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 *    of the Software, and to permit persons to whom the Software is furnished to do so,
 *    subject to the following conditions:
 *
 *    The above copyright notice and this permission notice shall be included in all copies
 *    or substantial portions of the Software.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 *    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 *    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 *    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 *    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 *    You should have received a copy of the MIT License along with Hubiquitus.
 *    If not, see <http://opensource.org/licenses/mit-license.php>.
 */

//Make it compatible with node and web browser
if (typeof define !== 'function') {
    var define = require('amdefine')(module)
}


define(
    ['./codes'],
    function (codes) {

        /**
         * Creates a new client that manages a connection and connects to the
         * hNode Server.
         */
        var HClient = function () {
            this._connectionStatus = codes.statuses.DISCONNECTED; //update by phonegap plugin
            this.fullUrn = null;
            this.resource = null;
            this.domain = null;
       
            cordova.exec(null, null, 'hapiPhoneGapPlugin', 'initClient', [
                {callback:String(callback)}
            ]);
        };

        HClient.prototype = {
            connect:function (login, password, options) {
                this.publisher = login;
                this.options = options;

                return cordova.exec(null, null, 'hapiPhoneGapPlugin', 'connect', [
                    {publisher:login, password:password, options:options, authCB:String(options.authCb) }
                ]);
            },
            disconnect:function () {
                this.publisher = null;
                return cordova.exec(null, null, 'hapiPhoneGapPlugin', 'disconnect', []);
            },

            subscribe:function (actor, callback) {
                cordova.exec(null, null, 'hapiPhoneGapPlugin', 'subscribe', [
                    {actor:actor, callback:String(callback)}
                ]);
            },

            unsubscribe:function (actor, callback) {
                cordova.exec(null, null, 'hapiPhoneGapPlugin', 'unsubscribe', [
                    {actor:actor, callback:String(callback)}
                ]);
            },

            send:function (hmessage, callback) {
                cordova.exec(null, null, 'hapiPhoneGapPlugin', 'send', [
                    {hmessage:hmessage, callback:String(callback)}
                ]);
            },

            getSubscriptions:function (callback) {
                cordova.exec(null, null, 'hapiPhoneGapPlugin', 'getSubscriptions', [
                    {callback:String(callback)}
                ]);
            },

            setFilter:function (filter, callback) {
                cordova.exec(null, null, 'hapiPhoneGapPlugin', 'setFilter', [
                    {filter:filter, callback:String(callback)}
                ]);
            },

            buildMessage:function (actor, type, payload, options) {
                options = options || {};

                if (!actor)
                    throw new Error('missing actor');

                if (!options.relevanceOffset)
                    return {
                        actor:actor,
                        convid:options.convid,
                        type:type,
                        priority:options.priority,
                        ref:options.ref,
                        relevance:options.relevance,
                        persistent:options.persistent,
                        location:options.location,
                        author:options.author,
                        published:options.published,
                        headers:options.headers,
                        timeout:parseInt(options.timeout),
                        payload:payload
                    };
                else{
                    var x=new Date();
                    var y=x.getTime()+ parseFloat(options.relevanceOffset);
                    return{
                        actor:actor,
                        convid:options.convid,
                        type:type,
                        priority:options.priority,
                        ref:options.ref,
                        relevance:(new Date(y)).getTime(),
                        persistent:options.persistent,
                        location:options.location,
                        author:options.author,
                        published:options.published,
                        headers:options.headers,
                        timeout:options.timeout,
                        payload:payload
                    };
                }

            },

            buildCommand:function (actor, cmd, params, filter, options) {
                if (!actor)
                    throw new Error('missing actor');
                else if (!cmd)
                    throw new Error('missing cmd');

                return this.buildMessage(actor, 'hCommand', {cmd:cmd, params:params, filter:filter}, options);
            },

            buildResult:function (actor, ref, status, result, options) {
                if (!actor)
                    throw new Error('missing actor');
                else if (!ref)
                    throw new Error('missing ref');
                else if (status == null)
                    throw new Error('missing status');
                if (!options)
                    options = {};
                options.ref = ref;
                return this.buildMessage(actor, 'hResult', {status:status, result:result}, options);
            },

            errors:codes.errors,
            statuses:codes.statuses,
            hResultStatus:codes.hResultStatus
        };

        cordova.addConstructor(function () {
            if (!window.plugins) {
                window.plugins = {};
            }
            window.plugins.hClient = new HClient();
        });
    }
)
