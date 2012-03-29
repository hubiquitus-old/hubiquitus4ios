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

function HCPhoneGapClient(username, password, callback, options) { this.initialize(username, password, callback, options) }

HCPhoneGapClient.prototype.test = function() {
    console.log("gonna do it");
    var service = 'HCPhoneGapClient';
    var action = 'test';
    var testOpt = { 'key' : 'value' };
    testOpt.key2 = 'ok';
    console.log("try : " + testOpt.key);
    var resCallback = function(result) {
        var res= eval("(" + result + ")");
        console.log("res : " + res.key);
    }
    
    Cordova.exec(resCallback, resCallback, service, action, [JSON.stringify(testOpt)]);
    
    console.log("done");

    
}

HCPhoneGapClient.install = function (username, password, callback, options) {
    if(!window.plugins) window.plugins = {};
    window.plugins.HCPhoneGapClient = new HCPhoneGapClient(username, password, callback, options);
    
    return window.plugins.HCPhoneGapClient;
}

HCPhoneGapClient.prototype.initialize = function (username, password, callback, options) {    
    //set callback function
    this.callback = callback;
    
    var args = {'username' : username, 'password' : password, callback : String(callback), 'options' : options};
    var service = 'HCPhoneGapClient';
    var action = 'initClient';
    
    function successed() {
    }
    
    function failed() {
    }
    
    Cordova.exec(successed, failed, service, action, [args]);
}

HCPhoneGapClient.prototype.connect = function () {
    var service = 'HCPhoneGapClient';
    var action = 'connect';
    
    function successed() {
    }
    
    function failed() {
    }
    
    Cordova.exec(successed, failed, service, action, []);
}

HCPhoneGapClient.prototype.disconnect  = function () {
    var service = 'HCPhoneGapClient';
    var action = 'disconnect';
    
    function successed() {
    }
    
    function failed() {
    }
    
    Cordova.exec(successed, failed, service, action, []);
}

HCPhoneGapClient.prototype.subscribe = function(channel) {
    var args = {'channel' : channel};
    var service = 'HCPhoneGapClient';
    var action = 'subscribe';
    
    function successed() {
    }
    
    function failed() {
    }
    
    Cordova.exec(successed, failed, service, action, [args]);
}

HCPhoneGapClient.prototype.unsubscribe = function(channel) {
    var args = {'channel' : channel};
    var service = 'HCPhoneGapClient';
    var action = 'unsubscribe';
    
    function successed() {
    }
    
    function failed() {
    }
    
    Cordova.exec(successed, failed, service, action, [args]);
}

HCPhoneGapClient.prototype.publish = function(channel, hMessage) {
    var args = {'channel' : channel, 'hMessage' : hMessage};
    var service = 'HCPhoneGapClient';
    var action = 'publish';
    
    function successed() {
    }
    
    function failed() {
    }
    
    Cordova.exec(successed, failed, service, action, [args]);
}

HCPhoneGapClient.prototype.getMessages = function(channel) {
    var args = {'channel' : channel};
    var service = 'HCPhoneGapClient';
    var action = 'getMessages';
    
    function successed() {
    }
    
    function failed() {
    }
    
    Cordova.exec(successed, failed, service, action, [args]);
}


//get default options, loaded from the hcoptions.plist if available
HCPhoneGapClient.defaultOptions = function(callback) {
    var opt = null;
    var service = 'HCPhoneGapClient';
    var action = 'defaultOptions';
    
    function successed(optionsObj) {
        opt = eval('(' + optionsObj + ')');
        callback(opt);
    }
    
    function failed() {
        opt = {};
        callback(opt);
    }
    
    Cordova.exec(successed, failed, service, action, []);
}

