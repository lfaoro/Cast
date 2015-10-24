//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//


import Cocoa
import RxSwift

final class MenuSendersAction: NSObject {

	var gistOptions: GistOptions
	let gist: GistClient


	override init() {
		self.gistOptions = GistOptions()
		self.gist = GistClient(options: gistOptions)
	}


	func shareClipboardContentsAction(sender: NSMenuItem) {
		let _ = getPasteboardItems()
			.debug("getPasteboardItems")
			.subscribe(next: { value in

				switch value {
				case .Text(let pbContents):
					self.gist.createGist(pbContents)
					self.gistOptions.updateGist = false

				case .Image(_):
					app.userNotification
						.pushNotification(error: "Not yet Supported :(",
							description: "Image support is on the way, hold tight!")

				case .File(let file):
					app.userNotification
						.pushNotification(error: "Not yet Supported :(",
							description: "File sharing support is on the way, hold tight!")
					print(file.path!)

				}
			})
	}

	func updateGistAction(sender: NSMenuItem) {
		self.gistOptions.updateGist = true
		shareClipboardContentsAction(sender)
	}


	func shortenURLAction(sender: NSMenuItem) {

		let _ = getPasteboardItems()
			.debug("getPasteboardItems")
			.subscribe(next: { value in
				switch value {
				case .Text(let item):
					guard let url = NSURL(string: item) else { fallthrough }
					shorten(withUrl: url)
						.subscribe { event in
							switch event {
							case .Next(let shortenedURL):
								guard let URL = shortenedURL else { fallthrough }
								putInPasteboard(items: [URL])
								app.userNotification.pushNotification(openURL: URL,
									title: "Shortened with \(userDefaults[.RecentActions])")

							case .Error:
								app.userNotification.pushNotification(
									error: "Unable to shorten URL",
									description: "\(url.standardizedURL!)"
								)

							case .Completed:
								print("completed")
							}
					}

				default:
					app.userNotification.pushNotification(error: "Not a valid URL")
				}
			})
	}

	func loginToGithub(sender: NSMenuItem) {
		app.oauth.authorize()
	}

	func logoutFromGithub(sender: NSMenuItem) {

		if let error = OAuthClient.revoke() {
			app.userNotification.pushNotification(error: error.localizedDescription)
		} else {
			app.statusBarItem.menu = createMenu(app.menuSendersAction)
			app.userNotification.pushNotification(error: "GitHub Authentication",
				description: "API key revoked internally")
		}
	}

	func recentUploadsAction(sender: NSMenuItem) {
		if let url = sender.representedObject as? NSURL {
			NSWorkspace.sharedWorkspace().openURL(url)
		} else {
			fatalError("No link in recent uploads")
		}
	}

//	func clearItemsAction(sender: NSMenuItem) {
//		if app.prefs.recentActions!.count > 0 {
//			app.prefs.recentActions!.removeAll()
//			Swift.print(app.prefs.recentActions!)
//			app.statusBarItem.menu = createMenu(app.menuSendersAction)
//		}
//	}

	func startAtLoginAction(sender: NSMenuItem) {
		if sender.state == 0 {
			sender.state = 1
		} else {
			sender.state = 0
		}
	}

	func optionsAction(sender: NSMenuItem) {
		NSApp.activateIgnoringOtherApps(true)
		app.optionsWindowController.showWindow(nil)
	}
}
