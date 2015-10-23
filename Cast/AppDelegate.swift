//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

// Cast: verb. throw (something) forcefully in a specified direction.

import Cocoa

//---------------------------------------------------------------------------
let app = (NSApp.delegate as? AppDelegate)!
//---------------------------------------------------------------------------

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var timer: NSTimer?
	var oauth: OAuthClient
	var statusBarItem: NSStatusItem!
	var menuSendersAction: MenuSendersAction!
	var userNotification: UserNotifications!
	var optionsWindowController: OptionsWindowController!


	override init() {

		var options: OAuthOptions = OAuthOptions()
		options.clientID = "ef09cfdbba0dfd807592"
		options.clientSecret = "ce7541f7a3d34c2ff5b20207a3036ce2ad811cc7"
		self.oauth = OAuthClient(options: options)

		super.init()
	}


	func applicationWillFinishLaunching(notification: NSNotification) {
		// Nothing to see here, move along.
	}

	func applicationDidFinishLaunching(aNotification: NSNotification) -> Void {

		userNotification = UserNotifications()
		statusBarItem = createStatusBar()
		menuSendersAction = MenuSendersAction()
		configureStatusBarItem(statusBarItem, target: menuSendersAction)

		optionsWindowController = OptionsWindowController()
	}

	func updateMenu() -> () {

		statusBarItem.menu?.update()
	}
}
