![](Resource/SDBridgeSwift.png)
![language](https://img.shields.io/badge/Language-Swift-green)
![language](https://img.shields.io/badge/support-Javascript/Async/Await-green)
[![Support](https://img.shields.io/badge/support-iOS%209%2B%20-FB7DEC.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![CocoaPods](https://img.shields.io/badge/pod-v1.0.3-green)](http://cocoapods.org/pods/SDBridgeSwift)
[![CocoaPods](https://img.shields.io/badge/support-SwiftPackageManagr-green)](https://www.swift.org/getting-started/#using-the-package-manager)

[SDBridgeOC](https://github.com/SDBridge/SDBridgeOC) is [here](https://github.com/SDBridge/SDBridgeOC).

If your h5 partner confused about how to deal with iOS and Android.
[This Demo maybe help](https://github.com/SDBridge/TypeScriptDemo).

### Installation with CocoaPods
Add this to your [podfile](https://guides.cocoapods.org/using/getting-started.html) and run `pod install` to install:

```ruby
pod 'SDBridgeSwift', '~> 1.0.3'
```
If you can't find the last version, maybe you need to update local pod repo.
```ruby
pod repo update
```

### Swift Package Manager
The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding SDBridgeSwift as a dependency is as easy as adding it to the dependencies value of your Package.swift.
```ruby
dependencies: [
    .package(url: "https://github.com/SDBridge/SDBridgeSwift", .upToNextMajor(from: "1.0.3"))
]
```

### Manual installation
Drag the `WebViewJavascriptBridge` folder into your project.

In the dialog that appears, uncheck "Copy items into destination group's folder" and select "Create groups for any folders".

Usage
-----

```Swift
var bridge: WebViewJavascriptBridge!
```
1) Instantiate bridge with a WKWebView:
```Swift
func setupView() {
        title = "WebViewController"
        view.backgroundColor = .white
        view.addSubview(webView)
        bridge = WebViewJavascriptBridge(webView: webView)
        
        // This can get javascript console.log
        bridge.consolePipeClosure = { water in
            guard let jsConsoleLog = water else {
                print("Javascript console.log give native is nil!")
                return
            }
            print("Next line is Javascript console.log----->>>>>>>")
            print(jsConsoleLog)
        }
        // This register for javascript call
        bridge.register(handlerName: "DeviceLoadJavascriptSuccess") { (parameters, callback) in
            let data = ["result":"iOS"]
            callback?(data)
        }
        let fileURL = URL.init(fileURLWithPath: Bundle.main.path(forResource: "Demo", ofType: "html")!)
        let request = URLRequest.init(url: fileURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15.0)
        webView.navigationDelegate = self;
        // Loading html in local ，This way maybe meet cross domain. So You should not forget to set
        // webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        // If you loading remote web server,That can be ignored.
        webView.load(request)
        view.addSubview(callJavascriptBtn)
        view.addSubview(callJSAsyncBtn)
    }
```

2)  In Swift, and call a Javascript Sync function:

```Swift
  @objc func callSyncFunction(_ sender:UIButton){
    let data = ["iOSKey": "iOSValue"]
    bridge.call(handlerName: "GetToken", data: data) { responseData in
        guard let res = responseData else {
            print("Javascript console.log give native is nil!")
            return
        }
        print(res)
    }
    }
```
3) In Swift, and call a Javascript Async function:
```Swift
  @objc func callJSAsyncFunction(_ sender:UIButton){
        let data = ["iOSKey": "iOSValue"]
        bridge.call(handlerName: "AsyncCall", data: data) { responseData in
            guard let res = responseData else {
                print("Javascript console.log give native is nil!")
                return
            }
            print(res)
        }
    }
```
4) In javascript file or typescript and html file like :
	
```javascript
<script>
    console.log("1111111111111");
    const bridge = window.WebViewJavascriptBridge;
    // JS tries to call the native method to judge whether it has been loaded successfully and let itself know whether its user is in android app or IOS app
    bridge.callHandler('DeviceLoadJavascriptSuccess', {key: 'JSValue'}, function(response) {
        let result = response.result
        if (result === "iOS") {
        console.log("Javascript was loaded by IOS and successfully loaded.");
        window.iOSLoadJSSuccess = true;
        } else if (result === "Android") {
        console.log("Javascript was loaded by Android and successfully loaded.");
        window.AndroidLoadJSSuccess = true;
       }
    });
    // JS register method is called by native
    bridge.registerHandler('GetToken', function(data, responseCallback) {
        console.log(data);
        let result = {token: "I am javascript's token"}
        //JS gets the data and returns it to the native
        responseCallback(result)
    });
    
    bridge.registerHandler('AsyncCall', function(data, responseCallback) {
        console.log(data);
        //Call await function must with  (async () => {})();
        (async () => {
            const callback = await generatorLogNumber(1);
            let result = {token: callback};
            responseCallback(result);
        })();
    });

    function generatorLogNumber(n){
        return new Promise(res => {
            setTimeout(() => {
            res("Javascript async/await callback Ok");
              }, 1000);
        });
     }
</script>
```
# Contact

- Email: housenkui@gmail.com

## License

SDBridgeSwift is released under the MIT license. [See LICENSE](https://github.com/SDBridge/SDBridgeSwift/blob/main/LICENSE) for details.
