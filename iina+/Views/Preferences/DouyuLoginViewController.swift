//
//  DouyuLoginViewController.swift
//  iina+
//
//  Created by Vizards on 2018/12/12.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa
import WebKit
import SwiftHTTP

class DouyuLoginViewController: NSViewController {
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var viewForWeb: NSView!
    @IBOutlet weak var waitProgressIndicator: NSProgressIndicator!
    var webView: WKWebView!
    var dismiss: (() -> Void)?
    let douyu = Douyu()
    @IBAction func tryAgain(_ sender: Any) {
        loadWebView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebView()
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyUp(with: event)
        switch event.keyCode {
        case 53:
            dismiss?()
        default:
            break
        }
    }
    
    
    func loadWebView() {
        tabView.selectTabViewItem(at: 0)
        
        let url = URL(string: "https://passport.douyu.com/index/login")
        let script = """
document.querySelector(".loginbox-close").remove();
document.querySelector(".third-text").remove();
document.querySelector(".third-list").remove();
"""
        
        // WebView Config
        let contentController = WKUserContentController()
        let scriptInjection = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(scriptInjection)
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        
        // Display Views
        waitProgressIndicator.isHidden = true
        webView = WKWebView(frame: viewForWeb.bounds, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        viewForWeb.subviews.removeAll()
        viewForWeb.addSubview(webView)
        webView.isHidden = false
        
        let request = URLRequest(url: url!);
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1"
        webView.load(request)
    }
    
    func displayWait() {
        webView.isHidden = true
        webView.stopLoading(self)
        waitProgressIndicator.isHidden = false
        waitProgressIndicator.startAnimation(self)
    }
}

extension DouyuLoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let str = webView.url?.absoluteString, str.contains("api") {
            displayWait()
            
            douyu.isLogin().done(on: .main) {
                if $0.0 {
                    self.dismiss?()
                } else {
                    self.tabView.selectTabViewItem(at: 1)
                }
                }.catch(on: .main) { _ in
                    self.tabView.selectTabViewItem(at: 1)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nserr = error as NSError
        if nserr.code == -1022 {
            Logger.log("NSURLErrorAppTransportSecurityRequiresSecureConnection")
        } else if let err = error as? URLError {
            switch(err.code) {
            case .cancelled:
                break
            case .cannotFindHost, .notConnectedToInternet, .resourceUnavailable, .timedOut:
                tabView.selectTabViewItem(at: 1)
            default:
                tabView.selectTabViewItem(at: 1)
                Logger.log("Error code: " + String(describing: err.code) + "  does not fall under known failures")
            }
        }
    }
}
