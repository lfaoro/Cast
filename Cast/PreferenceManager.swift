//
//  Created by Leonardo on 10/16/15.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa

// NSUserDefaults Keys in a variable to avoid mistakes
private let gistServiceKey = "gistService"
private let imageServiceKey = "imageService"
private let shortenServiceKey = "shortenService"
private let recentActionsKey = "recentActions"
private let secretGistsAvailableKey = "secretGistsAvailable"
private let gistIsPublicKey = "gistIsPublic"

class PreferenceManager {
	private let userDefaults = NSUserDefaults.standardUserDefaults()


	init() {
		registerDefaults()
	}


	func registerDefaults() {

		let standardDefaults = [
			gistServiceKey: "GitHub",
			imageServiceKey: "imgur",
			shortenServiceKey: "Is.Gd",
			recentActionsKey: ["Cast": "http://cast.lfaoro.com"],
			secretGistsAvailableKey: true,
			gistIsPublicKey: false,
		]

		userDefaults.registerDefaults(standardDefaults)
	}


	// MARK: - Gist Options

	var gistService: String? {
		get {
			return userDefaults.objectForKey(gistServiceKey) as? String
		}
		set {
			userDefaults.setObject(newValue, forKey: gistServiceKey)
		}
	}

	var secretGistsAvailable: Bool? {
		get {
			return userDefaults.objectForKey(secretGistsAvailableKey) as? Bool
		}
		set {
			userDefaults.setObject(newValue, forKey: secretGistsAvailableKey)
		}
	}

	var gistIsPublic: Bool? {
		get {
			return userDefaults.objectForKey(gistIsPublicKey) as? Bool
		}
		set {
			userDefaults.setObject(newValue, forKey: gistIsPublicKey)
		}
	}


	// MARK: - Image options

	var imageService: String? {
		get {
			return userDefaults.objectForKey(imageServiceKey) as? String
		}
		set {
			userDefaults.setObject(newValue, forKey: imageServiceKey)
		}
	}


	// MARK: - Shortening Options

	// Binded from OptionsWindow > Segmented control
	var shortenService: String? {
		get {
			return userDefaults.objectForKey(shortenServiceKey) as? String
		}
		set {
			userDefaults.setObject(newValue, forKey: shortenServiceKey)
		}
	}

	var recentActions: [String: String]? {
		get {
			return userDefaults.objectForKey(recentActionsKey) as? [String: String]
		}
		set {
			userDefaults.setObject(newValue, forKey: recentActionsKey)
			app.statusBarItem.menu = createMenu(app.menuSendersAction)
		}
	}

}
