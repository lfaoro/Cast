import Cocoa
import RxSwift
import RxCocoa
import SwiftyJSON

class RecentAction: NSObject {
	var desc: String!
	var url: NSURL!

	init(description: String, URL: NSURL) {
		super.init()

		self.desc = description
		self.url = URL
	}
}

func saveRecentAction(URL url: NSURL) {
	let description = String("\(url.host!)\(url.path!)".characters.prefix(30))

	var recentActions: [RecentAction] = userDefaults[.RecentActions] as! [RecentAction]
	recentActions.append(RecentAction(description: description, URL: url))
	userDefaults[.RecentActions] = recentActions

}


public enum ShortenService: Int {
	case Isgd = 0, Hive, Bitly, Supr, Vgd
}

class ShortenClient {
	var responseKey: String?

	func doShortenURL(service shortenService: ShortenService, url URL: NSURL) -> NSURL {
		var shortenURL: NSURL
		let shortenRequest: String

		switch shortenService {
		case .Isgd:
			let APIURL = "https://is.gd/create.php?format=json&url="
			shortenRequest = APIURL + URL.relativeString!

			shortenURL = NSURL(string: shortenRequest)!
			responseKey = "shorturl"

		case .Vgd:
			let APIURL = "https://v.gd/create.php?format=json&url="
			shortenRequest = APIURL + URL.relativeString!

			shortenURL = NSURL(string: shortenRequest)!
			responseKey = "shorturl"

		case .Hive:
			let APIURL = "https://hive.am/api?api=spublic&url="
			shortenRequest = APIURL + URL.relativeString!

			shortenURL = NSURL(string: shortenRequest)!
			responseKey = "short"

		case .Bitly:
			let APIurl = "https://api-ssl.bitly.com"
			shortenRequest = APIurl + "/v3/shorten?access_token=" +
				bitlyOAuth2Token + "&longUrl=" + URL.relativeString!

			shortenURL = NSURL(string: shortenRequest)!

		case .Supr:
			let APIURL = "http://su.pr/api/shorten?longUrl="
			let shortenRequest = APIURL + URL.relativeString!

			shortenURL = NSURL(string: shortenRequest)!
			responseKey = "shortUrl"

//		default: fatalError("ShortenURL Impossible for value \(shortenService)")
		}

		return shortenURL
	}

	func shorten(URL URL: NSURL) -> Observable<String?> {
//		keepRecent(URL: URL) TODO: Fix it

		let service = ShortenService(rawValue: userDefaults[.Shorten] as! Int)!

		let shortenURL = doShortenURL(service: service, url: URL)

		let session = NSURLSession.sharedSession()
		return session.rx_JSON(shortenURL)
			.debug("Shortening with: \(service)")
			.retry(3)
			.map {
				switch service {
				case .Bitly:
					guard let data = $0["data"] as? NSDictionary, url = data["url"] as? String
						else {
							return nil
					}

					return url

				default:
					return $0[self.responseKey!] as? String
				}
		}
	}
}
