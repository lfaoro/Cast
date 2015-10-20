//
//  Created by Leonardo on 10/17/15.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa

class OptionsWindowController: NSWindowController {

	override var windowNibName: String? {
		return "OptionsWindow"
	}

	@IBOutlet weak var loginButton: NSButton!

	override func windowDidLoad() {
		super.windowDidLoad()

		updateLoginButton()

	}

	@IBAction func secretGistButtonAction(sender: NSButton) {

		switch sender.state {

		case NSOnState:
			app.prefs.gistIsPublic = false

		case NSOffState:
			app.prefs.gistIsPublic = true

		default: return
		}
	}

	@IBAction func loginButtonAction(sender: NSButton) {

		switch sender.title {
		case "Login":
			app.oauth.authorize()

		case "Logout":
			if let error = OAuthClient.revoke() {
				app.userNotification.pushNotification(error: error.localizedDescription)
			} else {
				app.userNotification.pushNotification(error: "GitHub Authentication",
					description: "API key revoked internally")

				updateLoginButton()
			}

		default: return
		}
	}

	func updateLoginButton() {

		if OAuthClient.getToken() != nil {
			loginButton.title = "Logout"
		} else {
			loginButton.title = "Login"
		}
	}

	@IBAction func urlShorteningOptionsControl(sender: NSSegmentedCell) {

		let pref = PreferenceManager()
		print(pref.shortenService)
		print(pref.gistService)
	}

	@IBAction func gistServiceControl(sender: NSSegmentedControl) {
		print(__FUNCTION__)

		switch sender.labelForSegment(sender.selectedSegment)! {
		case "GitHub": app.prefs.secretGistsAvailable = true
		default: app.prefs.secretGistsAvailable = false
		}

	}

	@IBAction func openTwitterProfile(sender: NSButton) {

		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://twitter.com/leonarth")!)
	}

}
