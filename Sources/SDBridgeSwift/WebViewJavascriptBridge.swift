//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import WebKit
enum PipeType: String {
    case normal
    case console
}
public typealias ConsolePipeClosure = ((Any?) -> Void)

public class WebViewJavascriptBridge: NSObject {
    private weak var webView: WKWebView?
    private var base: WebViewJavascriptBridgeBase!
    public var consolePipeClosure: ConsolePipeClosure?
    public init(webView: WKWebView,_ otherJSCode: String = "") {
        super.init()
        self.webView = webView
        base = WebViewJavascriptBridgeBase()
        base.delegate = self
        addScriptMessageHandlers()
        injectJavascriptFile(otherJSCode)
    }
    deinit {
        print("\(type(of: self)) release")
        removeScriptMessageHandlers()
    }
    // MARK: - Public Funcs
    public func reset() {
        base.reset()
    }
    public func register(handlerName: String, handler: @escaping WebViewJavascriptBridgeBase.Handler) {
        base.messageHandlers[handlerName] = handler
    }
    public func remove(handlerName: String) -> WebViewJavascriptBridgeBase.Handler? {
        return base.messageHandlers.removeValue(forKey: handlerName)
    }
    public func call(handlerName: String, data: Any? = nil, callback: WebViewJavascriptBridgeBase.Callback? = nil) {
        base.send(handlerName: handlerName, data: data, callback: callback)
    }
   
    private func injectJavascriptFile(_ otherJSCode: String = "") {
//        let path = Bundle.main.path(forResource: "bridge", ofType: "js")
//        guard let bridgeJS1 = try? String.init(contentsOfFile: path!) else { return }
        let bridgeJS = JavascriptCode.bridge()
//        let path1 = Bundle.main.path(forResource: "hookConsole", ofType: "js")
//        guard let hookConsoleJS1 = try? String.init(contentsOfFile: path1!) else { return }
        let hookConsoleJS = JavascriptCode.hookConsole()
        let finalJS =  "\(bridgeJS)" + "\(hookConsoleJS)"
        let userScript = WKUserScript.init(source: finalJS, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(userScript)
        if !otherJSCode.isEmpty {
            let otherScript = WKUserScript.init(source: otherJSCode, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            webView?.configuration.userContentController.addUserScript(otherScript)
        }
    }
    private func addScriptMessageHandlers() {
        webView?.configuration.userContentController.add(LeakAvoider(delegate: self), name: PipeType.normal.rawValue)
        webView?.configuration.userContentController.add(LeakAvoider(delegate: self), name: PipeType.console.rawValue)
    }
    private func removeScriptMessageHandlers() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: PipeType.normal.rawValue)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: PipeType.console.rawValue)
    }
}
extension WebViewJavascriptBridge: WebViewJavascriptBridgeBaseDelegate {
    func evaluateJavascript(javascript: String, completion: CompletionHandler) {
        webView?.evaluateJavaScript(javascript, completionHandler: completion)
    }
}
extension WebViewJavascriptBridge: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == PipeType.console.rawValue {
            consolePipeClosure?(message.body)
        } else if message.name == PipeType.normal.rawValue {
            let body = message.body as? String
            guard let resultStr = body else {return}
            self.base.flush(messageQueueString: resultStr)
        }
    }
}
class LeakAvoider: NSObject {
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler) {
        super.init()
        self.delegate = delegate
    }
}
extension LeakAvoider: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
