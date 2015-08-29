//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa
import RxSwift
import RxCocoa

final class MenuSendersAction: NSObject {
	//---------------------------------------------------------------------------
	func shareClipboardContentsAction(sender: NSMenuItem) {
		let pasteboard = PasteboardController()
		var content: String = ""
		do {
			let data = try pasteboard.extractData()
			switch data {
			case .Text(let stringData):
				content = stringData
			default: app.userNotification.pushNotification(error: "The pasteboard is Empty or Unreadable")
			}
		} catch {
			app.userNotification.pushNotification(error: "\(error)")
		}

		app.gistClient.setGist(content: content)
			.debug("setGist")
			.retry(3)
			.flatMap { BitlyClient.shortenURL($0) }
			.subscribe { event in
				switch event {
				case .Next(let url):
					app.userNotification.pushNotification(openURL: url.absoluteString)
				case .Completed:
					app.statusBarItem.menu = createMenu(self)
				case .Error(let error):
					app.userNotification.pushNotification(error: String(error))
				}
		}
	}

	func loginToGithub(sender: NSMenuItem) {
		app.oauth.authorize()
	}

	func logoutFromGithub(sender: NSMenuItem) {
		let error = OAuthClient.revoke()

		if let error = error {
			app.userNotification.pushNotification(error: error.localizedDescription)
		} else {
			app.statusBarItem.menu = createMenu(self)
		}
	}

	//---------------------------------------------------------------------------
	func recentUploadsAction(sender: NSMenuItem) {
		let url = NSURL(string: (sender.representedObject as? String)!)
		if let url = url {
			NSWorkspace.sharedWorkspace().openURL(url)
		} else {
			fatalError("No link in recent uploads")
		}
	}
	//---------------------------------------------------------------------------
	func clearItemsAction(sender: NSMenuItem) {
		if recentUploads.count > 0 {
			recentUploads.removeAll()
			Swift.print(recentUploads)
			app.updateMenu()
		}
	}
	//---------------------------------------------------------------------------
	func startAtLoginAction(sender: NSMenuItem) {
		if sender.state == 0 {
			sender.state = 1
		} else {
			sender.state = 0
		}
	}
	//---------------------------------------------------------------------------
	func openOptionsWindow(sender: NSMenuItem) {
		app.options.displayOptionsWindow()
	}
}
