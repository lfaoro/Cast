//
//  AppDelegate.swift
//  Cast
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

		gistClient = GistClient()
		userNotification = UserNotifications()
		statusBarItem = createStatusBar()
		menuSendersAction = MenuSendersAction()
		configureStatusBarItem(statusBarItem, target: menuSendersAction)
	}

	func updateMenu() -> () {

		statusBarItem.menu?.update()
	}
}

//MARK:- Globals

//TODO: Absolutely refactor this, find a way to encapsulate all of the code below.

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

	print(statusBarItem.button?.window?.frame)
}

func createMenu(target: MenuSendersAction) -> NSMenu {

	let menu = NSMenu(title: "Cast Menu")

	menu.addItemWithTitle("Share Pasteboard Contents",
		action: "shareClipboardContentsAction:",
		keyEquivalent: "S")?
		.target = target

	if app.gistClient.gistCreated {

		menu.addItemWithTitle("Update current gist",
			action: "updateGistAction:",
			keyEquivalent: "U")?
			.target = target
	}

	menu.addItemWithTitle("Shorten URL with Hive",
		action: "shortenURLAction:",
		keyEquivalent: "T")?
		.target = target

	menu.addItem(NSMenuItem.separatorItem())

	///- todo: externalise in separate function
	///- todo: implement recent gists
	let recentUploadsItem = NSMenuItem(title: "Recent Uploads",
		action: "terminate:",
		keyEquivalent: "")

	let recentUploadsSubmenu = NSMenu(title: "Cast - Recent Uploads Menu")
	for (title, link) in recentURLS  {
		let menuItem = NSMenuItem(title: title,
			action: "recentUploadsAction:",
			keyEquivalent: "")
		// Allows me to use a value from this context in the func called by the selector
		menuItem.representedObject = NSURL(string: link)
		menuItem.target = target
		recentUploadsSubmenu.addItem(menuItem)
	}
	recentUploadsSubmenu.addItem(NSMenuItem.separatorItem())
	recentUploadsSubmenu.addItemWithTitle("Clear Recents",
		action: "clearItemsAction:",
		keyEquivalent: "")?.target = target

	recentUploadsItem.submenu = recentUploadsSubmenu

	if recentURLS.count > 0 {
		menu.addItem(recentUploadsItem)
	}

	menu.addItem(NSMenuItem.separatorItem())

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

// TODO: Find a place for Recent URLs DB
var recentURLS: [String: String] {
get {
	let userDefaults = NSUserDefaults.standardUserDefaults()

	guard let dic = userDefaults.dictionaryForKey("recentURLS") as? [String: String] else
	{ return ["Cast": "http://cast.lfaoro.com"] }

	return dic
}

set (value) {
	let userDefaults = NSUserDefaults.standardUserDefaults()
	userDefaults.setObject(value, forKey: "recentURLS")
	app.statusBarItem.menu = createMenu(app.menuSendersAction)
}
}

func keepRecent(URL url: NSURL) {
	let description = String("\(url.host!)\(url.path!)".characters.prefix(30))

	recentURLS[description] = url.relativeString!
	
}
