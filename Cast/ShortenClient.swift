import Cocoa
import RxSwift
import RxCocoa
import SwiftyJSON


class RecentAction: NSObject, NSCoding {
    var desc: String
    var url: NSURL

    init(description: String, URL: NSURL) {
        self.desc = description
        self.url = URL
    }

    required init?(coder aDecoder: NSCoder) {
        self.desc = aDecoder.decodeObjectForKey("description") as! String
        self.url = aDecoder.decodeObjectForKey("url") as! NSURL
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(desc, forKey: "description")
        aCoder.encodeObject(url, forKey: "url")
    }
}

func saveRecentAction(URL url: NSURL) {
    let description = String("\(url.host!)\(url.path!)".characters.prefix(30))

	var recentActions = userDefaults[.RecentActions] as! [String: String]
	recentActions[description] = url.absoluteString
    userDefaults[.RecentActions] = recentActions
	app.statusBarItem.menu = createMenu(app.menuSendersAction)
}


enum ShortenService: Int {
    case Isgd = 0
    case Hive
    case Bitly
    case Vgd

    func makeURL(url URL: NSURL) -> (url: String, responseKey: String?) {
        switch self {
        case .Isgd:
            return (url: "https://is.gd/create.php?format=json&url=" + URL.relativeString!,
				responseKey: "shorturl")

        case .Vgd:
            return (url: "https://v.gd/create.php?format=json&url=" + URL.relativeString!,
				responseKey: "shorturl")

        case .Hive:
            return (url: "https://hive.am/api?api=spublic&url=" + URL.relativeString!,
				responseKey: "short")

        case .Bitly:
            return (url: "https://api-ssl.bitly.com/v3/shorten?access_token=" +
				bitlyOAuth2Token + "&longUrl=" + URL.relativeString!,
				responseKey: nil)
		}
    }
}


func shorten(withUrl url: NSURL) -> Observable<String?> {
	saveRecentAction(URL: url)

    let session = NSURLSession.sharedSession()
    let service = ShortenService(rawValue: userDefaults[.ShortenService] as! Int)! //TODO: Fix me

    let ( _url, responseKey) = service.makeURL(url: url)

    return session.rx_JSON(NSURL(string: _url)!) //TODO: Fix me (!)
    .debug("Shortening with: \(service)")
    .retry(3)
    .map {
        switch service {
        case .Bitly:
            guard let data = $0["data"] as? NSDictionary, url = data["url"] as? String else {
                return nil
            }

            return url

        default:
            return $0[responseKey!] as? String
        }
    }
}
