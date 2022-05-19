//
//  WebViewController.swift
//  JavascriptBridgeSwift
//
//  Created by 1 on 2022/3/22.
//

import UIKit
import WebKit
let KScreenWidth = UIScreen.main.bounds.size.width
let KScreenHeight = UIScreen.main.bounds.size.height
class WebViewController: UIViewController {
    var bridge: WebViewJavascriptBridge!
    lazy var webView: WKWebView = {
        let webView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight ), configuration: WKWebViewConfiguration())
        // Allow cross domain
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        webView.isOpaque = false
        return webView
    }()
    lazy var callJavascriptBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 40, y: KScreenHeight - 100, width: 150, height: 40)
        button.setTitle("callSyncBtn" , for: .normal)
        button.addTarget(self, action: #selector(callSyncFunction), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6
        button.backgroundColor = .brown
        return button
    }()
    
    lazy var callJSAsyncBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: KScreenWidth - 200, y: KScreenHeight - 100, width: 150, height: 40)
        button.setTitle("callAsyncBtn" , for: .normal)
        button.addTarget(self, action: #selector(callJSAsyncFunction), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6
        button.backgroundColor = .brown
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
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
        
        // index.html use SDBridge.js. This js file was create by webpack.
//        let fileURL = URL.init(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)

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
    @objc func callSyncFunction(_ sender:UIButton){
        let data = ["iOSKey00": "iOSValue00"]
        bridge.call(handlerName: "GetToken", data: data) { responseData in
            guard let res = responseData else {
                print("Javascript console.log give native is nil!")
                return
            }
            print(res)
        }
    }
    @objc func callJSAsyncFunction(_ sender:UIButton){
        let data = ["iOSKey01": "iOSValue01"]
        bridge.call(handlerName: "AsyncCall", data: data) { responseData in
            guard let res = responseData else {
                print("Javascript console.log give native is nil!")
                return
            }
            print(res)
        }
    }
    
    deinit {
        print("\(type(of: self)) release")
    }
}
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod  ==  NSURLAuthenticationMethodServerTrust {
            let card = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential,card)
        }
    }
}
