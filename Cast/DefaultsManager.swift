//
//  Created by Leonardo on 10/16/15.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa


// MARK:- NSUserDefaults Abstraction
var userDefaults = UserDefaults()

enum ServiceKey: String {
	case GistService
	case GistIsPublic
	case ShortenService
	case Image
	case RecentActions
}

struct UserDefaults {
	let userDefaults = NSUserDefaults.standardUserDefaults()

	init() {
		registerDefaults()
	}

	subscript (key: ServiceKey) -> AnyObject {
		get {
			guard let value = userDefaults.objectForKey(key.rawValue) else {
				fatalError("You forgot to provide a default value for all ServiceKey cases")
			}
			return value
		}
		set {
			userDefaults.setObject(newValue, forKey: key.rawValue)
		}
	}

	/// Default values to provide in absense of user provided defaults
	func registerDefaults() {
		let registeredDefaults: [String: AnyObject] = [
			ServiceKey.GistService.rawValue: GistService.GitHub.rawValue,
			ServiceKey.GistIsPublic.rawValue: false,
			ServiceKey.ShortenService.rawValue: ShortenService.Isgd.rawValue,
			ServiceKey.Image.rawValue: "Imgur",
			ServiceKey.RecentActions.rawValue: [],
		]

		userDefaults.registerDefaults(registeredDefaults)
	}
}
