import Cocoa
import RxSwift
import RxCocoa
import SwiftyJSON


func keepRecent(URL url: NSURL) {
    let description = String("\(url.host!)\(url.path!)".characters.prefix(30))
    app.prefs.recentActions![description] = url.relativeString!
}

class ShortenClient {
    var shortenURL: NSURL?
    var responseKey: String?

    func doShortenURL(service shortenService: String, url URL: NSURL) -> NSURL? {
        let shortenRequest: String

        switch shortenService {
        case "Is.Gd":
            let APIURL = "https://is.gd/create.php?format=json&url="
            shortenRequest = APIURL + URL.relativeString!

            shortenURL = NSURL(string: shortenRequest)!
            responseKey = "shorturl"

        case "v.gd":
            let APIURL = "https://v.gd/create.php?format=json&url="
            shortenRequest = APIURL + URL.relativeString!

            shortenURL = NSURL(string: shortenRequest)!
            responseKey = "shorturl"

        case "Hive.am":
            let APIURL = "https://hive.am/api?api=spublic&url="
            shortenRequest = APIURL + URL.relativeString!

            shortenURL = NSURL(string: shortenRequest)!
            responseKey = "short"

        case "Bit.ly":
            let APIurl = "https://api-ssl.bitly.com"
            shortenRequest = APIurl + "/v3/shorten?access_token=" + bitlyOAuth2Token + "&longUrl=" + URL.relativeString!

            shortenURL = NSURL(string: shortenRequest)!

        case "Su.Pr":
            let APIURL = "http://su.pr/api/shorten?longUrl="
            let shortenRequest = APIURL + URL.relativeString!

            shortenURL = NSURL(string: shortenRequest)!
            responseKey = "shortUrl"

        default: shortenURL = nil
        }

        return shortenURL
    }

    func shorten(URL URL: NSURL) -> Observable<String?> {
        guard let shortenService = app.prefs.shortenService else {
            return failWith(ConnectionError.InvalidData("shortenService"))
        }

        keepRecent(URL: URL)
        if let shortenURL = doShortenURL(service: shortenService, url: URL) {
            let session = NSURLSession.sharedSession()
            return session.rx_JSON(shortenURL)
            .debug("Shortening with: \(shortenService)")
            .retry(3)
            .map {
                switch shortenService {
                case "Bit.ly":
                    guard let data = $0["data"] as? NSDictionary, url = data["url"] as? String
                    else {
                        return nil
                    }

                    return url

                default:
                    return $0[self.responseKey!] as? String
                }
            }
        } else {
            return failWith(ConnectionError.InvalidData("shortenService"))
        }
    }
}
