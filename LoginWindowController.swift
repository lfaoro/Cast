//
//  LoginWindowController.swift
//  Cast
//
//  Created by Leonardo on 30/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import WebKit

/// Very many thanks to [mikeash](https://mikeash.com/) who taught me how to use .xibs
/// with one [blog post](https://mikeash.com/pyblog/friday-qa-2013-04-05-windows-and-window-controllers.html)
public class LoginWindowController: NSWindowController {


	@IBOutlet weak var loginView: NSView!
	public var loginWebView: WKWebView!

    override public func windowDidLoad() {
        super.windowDidLoad()
		print("viewDidLoad")



		loginWebView = WKWebView(frame: loginView.frame)
		loginWebView.navigationDelegate = self

		loginView.addSubview(loginWebView)


		//		let request = NSURLRequest(URL: NSURL(string: "http://www.apple.com")!)
		//		loginWebView.loadRequest(request)

    }
    
}

extension LoginWindowController: WKNavigationDelegate {
	public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
		//TODO: Finish implementation to open callback URL
	}
}
