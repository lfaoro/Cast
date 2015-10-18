//
//  Created by Leonardo on 10/16/15.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa

// Keys in a variable to avoid mistakes
private let gistServiceKey = "gistService"
private let imageServiceKey = "imageService"
private let shortenServiceKey = "shortenService"
private let recentActionsKey = "recentActions"
private let secretGistsAvailableKey = "secretGistsAvailable"

class PreferenceManager {
	private let userDefaults = NSUserDefaults.standardUserDefaults()


	init() {
		registerDefaults()
	}


	func registerDefaults() {

		let standardDefaults = [
			gistServiceKey: "GitHub",
			imageServiceKey: "imgur",
			shortenServiceKey: "is.gd",
			recentActionsKey: ["Cast": "http://cast.lfaoro.com"],
			secretGistsAvailableKey: true,
		]

		userDefaults.registerDefaults(standardDefaults)
	}


	// MARK: - Defaults properties abstraction

	// MARK: Gist Options
	var gistService: String? {
		get {
			return userDefaults.objectForKey(gistServiceKey) as? String
		}
		set {
			userDefaults.setObject(newValue, forKey: gistServiceKey)
			switch newValue! {
			case "GitHub": secretGistsAvailable = true
			default: secretGistsAvailable = false
			}
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

	// MARK: Image options
	var imageService: String? {
		get {
			return userDefaults.objectForKey(imageServiceKey) as? String
		}
		set {
			userDefaults.setObject(newValue, forKey: imageServiceKey)
		}
	}


	// MARK: Shortening Options

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
