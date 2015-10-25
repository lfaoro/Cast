//
//  Created by Leonardo on 10/23/15.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa


//TODO: Absolutely refactor this

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

	let gistOptions = GistOptions()
	if gistOptions.gistID != nil {
		menu.addItemWithTitle("Update latest gist",
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
	let recentActions = userDefaults[.RecentActions] as! [String: String]
	for (title, link) in recentActions {
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

	if recentActions.count > 0 {
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
