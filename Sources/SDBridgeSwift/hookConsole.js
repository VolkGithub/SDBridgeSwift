;(function(window) {
    let printObject = function (obj) {
        let output = "";
        if (obj === null) {
            output += "null";
        }
        else  if (typeof(obj) == "undefined") {
            output += "undefined";
        }
        else if (typeof obj ==='object'){
            output+="{";
            for(let key in obj){
                let value = obj[key];
                output+= "\""+key+"\""+":"+"\""+value+"\""+",";
            }
            output = output.substr(0, output.length - 1);
            output+="}";
        }
        else {
            output = "" + obj;
        }
        return output;
    };
    window.console.log = (function (oriLogFunc,printObject) {
        return function (str) {
            str = printObject(str);
            window.webkit.messageHandlers.console.postMessage(str);
            oriLogFunc.call(window.console, str);
        }
    })(window.console.log,printObject);

})(window);
