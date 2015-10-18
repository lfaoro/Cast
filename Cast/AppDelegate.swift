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
	var prefs: PreferenceManager!
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

		prefs = PreferenceManager()
		gistClient = GistClient()
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

	menu.addItemWithTitle("Share copied text",
		action: "shareClipboardContentsAction:",
		keyEquivalent: "S")?
		.target = target

	if app.gistClient.gistCreated {

		menu.addItemWithTitle("Update current gist",
			action: "updateGistAction:",
			keyEquivalent: "U")?
			.target = target
	}

	menu.addItemWithTitle("Shorten URL",
		action: "shortenURLAction:",
		keyEquivalent: "T")?
		.target = target

	menu.addItem(NSMenuItem.separatorItem())

	///- todo: externalise in separate function
	let recentUploadsItem = NSMenuItem(title: "Recent Actions",
		action: "terminate:",
		keyEquivalent: "")

	let recentUploadsSubmenu = NSMenu(title: "Cast - Recent Actions Menu")
	for (title, link) in app.prefs.recentActions! {
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

	if app.prefs.recentActions!.count > 0 {
		menu.addItem(recentUploadsItem)
	}

//	menu.addItem(NSMenuItem.separatorItem())

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
//	menu.addItem(gitHubLoginItem)

	menu.addItem(NSMenuItem.separatorItem())
	menu.addItemWithTitle("Options", action: "optionsAction:", keyEquivalent: "O")?
		.target = target

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


func keepRecent(URL url: NSURL) {
	let description = String("\(url.host!)\(url.path!)".characters.prefix(30))

	app.prefs.recentActions![description] = url.relativeString!

}
