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
class LoginWindowController: NSWindowController {


	@IBOutlet weak var loginView: NSView!
	var loginWebView: WKWebView!

    override func windowDidLoad() {
        super.windowDidLoad()
		print("viewDidLoad")

		loginWebView = WKWebView(frame: loginView.frame)
		loginView.addSubview(loginWebView)

		let request = NSURLRequest(URL: NSURL(string: "http://www.apple.com")!)
		loginWebView.loadRequest(request)

    }
    
}
