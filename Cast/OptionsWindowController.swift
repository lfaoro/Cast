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
	@IBOutlet weak var secretGistButton: NSButton!

	override func windowDidLoad() {
		super.windowDidLoad()

		updateLoginButton()

	}

	/// Binded to userDefaults[.GistIsPublic]
	@IBAction func secretGistButtonAction(sender: NSButton) {

//		userDefaults[.GistIsPublic] = sender.state == NSOnState
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

	/// Binded to userDefaults[.Shorten]
	@IBAction func urlShortenerSegmentedControlAction(sender: NSSegmentedCell) {

	}

	@IBAction func gistServiceSegmentedControlAction(sender: NSSegmentedControl) {

		switch GistService(rawValue: sender.selectedSegment)! {
		case .GitHub:
			secretGistButton.enabled = true
		default:
			secretGistButton.enabled = false
		}

	}

	@IBAction func openTwitterProfile(sender: NSButton) {

		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://twitter.com/leonarth")!)
	}

}
