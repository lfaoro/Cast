//
//  AppDelegate.swift
//  Cast
//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
// Cast: verb. throw (something) forcefully in a specified direction.

import Cocoa
import SwiftyJSON

//---------------------------------------------------------------------------
let app = (NSApp.delegate as? AppDelegate)!
//---------------------------------------------------------------------------

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var oauth: OAuthClient
	var statusBarItem: NSStatusItem!
	var menuSendersAction: MenuSendersAction!
	var webAPI: WebAPIs!
	var userNotification: UserNotifications!
	var options: Options!
	var gistClient: GistClient!


	override init() {

		self.oauth = OAuthClient(
			clientID: "ef09cfdbba0dfd807592",
			clientSecret: "ce7541f7a3d34c2ff5b20207a3036ce2ad811cc7",
			service: .GitHub
			)!

		super.init()
	}


	func applicationWillFinishLaunching(notification: NSNotification) {
	}

	func applicationDidFinishLaunching(aNotification: NSNotification) -> Void {

		statusBarItem = createStatusBar()
		menuSendersAction = MenuSendersAction()
		configureStatusBarItem(statusBarItem, target: menuSendersAction)
		webAPI = WebAPIs()
		userNotification = UserNotifications()
		options = Cast.Options()
		gistClient = GistClient()
	}

	func updateMenu() -> () {

		statusBarItem.menu?.update()
	}
}

//MARK:- Globals

func createStatusBar() -> NSStatusItem {
	return NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
}

func configureStatusBarItem(statusBarItem: NSStatusItem, target: MenuSendersAction) -> () {
	statusBarItem.button?.title = "Cast"
	let image = NSImage(named: "StatusBarIcon")
	image?.template = true
	statusBarItem.button?.image = image
	statusBarItem.button?.alternateImage = NSImage(named: "LFStatusBarAlternateIcon")
	statusBarItem.button?.registerForDraggedTypes(pasteboardTypes)
	statusBarItem.menu = createMenu(target)
}

func createMenu(target: MenuSendersAction) -> NSMenu {

	let menu = NSMenu(title: "Cast Menu")
	menu.addItemWithTitle("Share",
		action: "shareClipboardContentsAction:",
		keyEquivalent: "S")?.target = target

	let gitHubLoginItem = NSMenuItem()
	gitHubLoginItem.target = target
	gitHubLoginItem.keyEquivalent = "L"
	if OAuthClient.getToken() != nil {
		gitHubLoginItem.title = "Logout from GitHub"
		gitHubLoginItem.action = "logoutFromGithub:"
	} else {
		gitHubLoginItem.title = "Login to GitHub"
		gitHubLoginItem.action = "loginToGithub:"
	}

	menu.addItem(gitHubLoginItem)
	menu.addItem(NSMenuItem.separatorItem())

	//---------------------------------------------------------------------------
	///- todo: externalise in separate function
	///- todo: implement recent gists
	let recentUploadsItem = NSMenuItem(title: "Recent Uploads",
		action: "terminate:",
		keyEquivalent: "")
	let recentUploadsSubmenu = NSMenu(title: "Cast - Recent Uploads Menu")
	if !recentUploads.isEmpty {
		for (title,link) in recentUploads {
			let menuItem = NSMenuItem(title: title,
				action: "recentUploadsAction:",
				keyEquivalent: "")
			// Allows me to use a value from this context in the func called by the selector
			menuItem.representedObject = link
			menuItem.target = target
			recentUploadsSubmenu.addItem(menuItem)
		}
	}
	recentUploadsSubmenu.addItem(NSMenuItem.separatorItem())
	recentUploadsSubmenu.addItemWithTitle("Clear Recents",
		action: "clearItemsAction:",
		keyEquivalent: "")?.target = target
	recentUploadsItem.submenu = recentUploadsSubmenu

	//	menu.addItem(recentUploadsItem)
	//---------------------------------------------------------------------------

	//	menu.addItemWithTitle("Start at Login",
	//		action: "startAtLoginAction:",
	//		keyEquivalent: "")?.target = target
	//	menu.addItemWithTitle("Options",
	//		action: "openOptionsWindow:",
	//		keyEquivalent: "")?.target = target
	menu.addItemWithTitle("Quit",
		action: "terminate:",
		keyEquivalent: "Q")

	return menu
}
