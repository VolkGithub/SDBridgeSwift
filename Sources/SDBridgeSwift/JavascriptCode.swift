//
//  JavascriptCode.swift
//  JavascriptBridgeSwift
//
//  Created by HSK on 2022/5/13.
//

import Foundation
struct JavascriptCode {
    public static func bridge() ->String {
        let bridgeJS = """
        ;(function(window) {
            window.WebViewJavascriptBridge = {
                registerHandler: registerHandler,
                callHandler: callHandler,
                handleMessageFromNative: handleMessageFromNative
            };
            var messageHandlers = {};
            var responseCallbacks = {};
            var uniqueId = 1;
            function registerHandler(handlerName, handler) {
                messageHandlers[handlerName] = handler;
            }
            function callHandler(handlerName, data, responseCallback) {
                if (arguments.length === 2 && typeof data == 'function') {
                    responseCallback = data;
                    data = null;
                }
                doSend({ handlerName:handlerName, data:data }, responseCallback);
            }
            function doSend(message, responseCallback) {
                if (responseCallback) {
                    var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
                    responseCallbacks[callbackId] = responseCallback;
                    message['callbackId'] = callbackId;
                }
                window.webkit.messageHandlers.normal.postMessage(JSON.stringify(message));
            }
            function handleMessageFromNative(messageJSON) {
                var message = JSON.parse(messageJSON);
                var messageHandler;
                var responseCallback;
                if (message.responseId) {
                    responseCallback = responseCallbacks[message.responseId];
                    if (!responseCallback) {
                        return;
                    }
                    responseCallback(message.responseData);
                    delete responseCallbacks[message.responseId];
                } else {
                    if (message.callbackId) {
                        var callbackResponseId = message.callbackId;
                        responseCallback = function(responseData) {
                            doSend({ handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData });
                        };
                    }
                    var handler = messageHandlers[message.handlerName];
                    if (!handler) {
                        console.log("WebViewJavascriptBridge: WARNING: no handler for message from Swift:", message);
                    } else {
                        handler(message.data, responseCallback);
                    }
                }
            }
        })(window);
        """
        return bridgeJS
    }
    
    public static func hookConsole() ->String {
        let hookConsole = """
        ;(function(window) {\n    let printObject = function (obj) {\n        let output = \"\";\n        if (obj === null) {\n            output += \"null\";\n        }\n        else  if (typeof(obj) == \"undefined\") {\n            output += \"undefined\";\n        }\n        else if (typeof obj ===\'object\'){\n            output+=\"{\";\n            for(let key in obj){\n                let value = obj[key];\n                output+= \"\\\"\"+key+\"\\\"\"+\":\"+\"\\\"\"+value+\"\\\"\"+\",\";\n            }\n            output = output.substr(0, output.length - 1);\n            output+=\"}\";\n        }\n        else {\n            output = \"\" + obj;\n        }\n        return output;\n    };\n    window.console.log = (function (oriLogFunc,printObject) {\n        return function (str) {\n            str = printObject(str);\n            window.webkit.messageHandlers.console.postMessage(str);\n            oriLogFunc.call(window.console, str);\n        }\n    })(window.console.log,printObject);\n\n})(window);\n
        """
        return hookConsole
    }
}
