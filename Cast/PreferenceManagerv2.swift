//
//  Created by Leonardo on 10/16/15.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa


// MARK:- NSUserDefaults Abstraction
var userDefaults = UserDefaults()

enum ServiceKey: String {
	case Gist
	case GistIsPublic
	case Shorten
	case Image
	case RecentActions
}

struct UserDefaults {

	let userDefaults = NSUserDefaults.standardUserDefaults()

	init() {
		self[.Gist] = GistService.GitHub.rawValue
		self[.GistIsPublic] = false
		self[.Shorten] = ShortenService.Isgd.rawValue
		self[.Image] = "Imgur"
		self[.RecentActions] = []
	}

	subscript (category: ServiceKey) -> AnyObject {
		get {
			guard let value = userDefaults.objectForKey(category.rawValue) else {
				fatalError("You forgot to provide a default value for all ServiceKey cases")
			}
			return value
		}
		set {
			userDefaults.setObject(newValue, forKey: category.rawValue)
		}
	}
}