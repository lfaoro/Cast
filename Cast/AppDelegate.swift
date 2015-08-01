//
//  AppDelegate.swift
//  Cast
//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


	var timer: NSTimer!

	//---------------------------------------------------------------------------
	let statusBar = LFStatusBar()
	//---------------------------------------------------------------------------
	func applicationDidFinishLaunching(aNotification: NSNotification) {
//		statusBar.api.pasteboard.notification.notifcationTimer()

//		timer = NSTimer.scheduledTimerWithTimeInterval(
//			5.0,
//			target: self,
//			selector: "removeNotifcationAction:",
//			userInfo: nil,
//			repeats: true)
//

	}
//	func removeNotifcationAction(sender: AnyObject) {
//		print(__FUNCTION__)
//	}


	//---------------------------------------------------------------------------
	override func awakeFromNib() {
		//create the statusbar and its menu and installs it on the systemstatusbar (3)
		statusBar.displayStatusBarItem()
	}
	//---------------------------------------------------------------------------
	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}
	//---------------------------------------------------------------------------
}

