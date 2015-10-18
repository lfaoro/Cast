import Cocoa
import RxSwift
import RxCocoa
import SwiftyJSON


public class ShortenClient {

	var shortenURL: NSURL?
	var responseKey: String?


	// MARK: - Public

	public func shorten(URL URL: NSURL) -> Observable<String?> {
		guard let shortenURLPref = app.prefs.shortenService else {
			return failWith(ConnectionError.InvalidData("shortenURLPref"))
		}

		keepRecent(URL: URL)

		switch shortenURLPref {
		case "Is.Gd":
			shortenURL = NSURL(string: "https://is.gd/create.php?format=json&url=" +
				URL.absoluteString)!
			responseKey = "shorturl"

		case "Hive":
			self.shortenURL = NSURL(string: "https://hive.am/api?api=spublic&url=\(URL.absoluteString)" +
				"&description=cast.lfaoro.com&type=DIRECT")!
			responseKey = "short"

		case "Bitly":
			let bitlyAPIurl = "https://api-ssl.bitly.com"
			let bitlyAPIshorten = bitlyAPIurl + "/v3/shorten?access_token=" + bitlyOAuth2Token +
				"&longUrl=" + URL.relativeString!
			shortenURL = NSURL(string: bitlyAPIshorten)!

		default: shortenURL = nil
		}

		let session = NSURLSession.sharedSession()
		return session.rx_JSON(shortenURL!)
			.debug("Shortening with: \(shortenURLPref)")
			.retry(3)
			.map {

				if shortenURLPref != "Bitly" {
					return $0[self.responseKey!] as? String
				} else {
					guard let data = $0["data"] as? NSDictionary, url = data["url"] as? String else {
						return nil }
					return url
				}
		}
	}


	@available(*, deprecated=1.2, renamed="shorten")
	public class func shortenWithIsGd(URL URL: NSURL) -> Observable<String?> {
		let session = NSURLSession.sharedSession()
		let shorten = NSURL(string: "https://is.gd/create.php?format=json&url=" + URL.absoluteString)!

		keepRecent(URL: URL)

		return session.rx_JSON(shorten)
			.debug("shorten")
			.retry(3)
			.map { $0["shorturl"] as? String }
	}

	@available(*, deprecated=1.2, renamed="shorten")
	public class func shortenWithHive(URL URL: NSURL) -> Observable<String?> {



		let hiveAPIURL = "https://hive.am/api?api=spublic&url=\(URL.absoluteString)" +
		"&description=cast.lfaoro.com&type=DIRECT"

		let session = NSURLSession.sharedSession()
		let shorten = NSURL(string: hiveAPIURL)!

		return session.rx_JSON(shorten)
			.retry(3)
			.map { $0["short"] as? String }
	}

	@available(*, deprecated=1.2, renamed="shorten")
	public class func shortenWithBitly(URL: NSURL) -> Observable<NSURL> {
		let bitlyAPIurl = "https://api-ssl.bitly.com"
		let bitlyAPIshorten = bitlyAPIurl + "/v3/shorten?access_token=" + bitlyOAuth2Token +
			"&longUrl=" + URL.relativeString!
		let url = NSURL(string: bitlyAPIshorten)!

		return create { stream in
			let session = NSURLSession.sharedSession()
			session.dataTaskWithURL(url) { (data, response, error) in
				if let data = data {
					let jsonData = JSON(data: data)
					let statusCode = jsonData["status_code"].int
					if statusCode == 200 {
						if let shortenedURL = jsonData["data"]["url"].URL {
							sendNext(stream, shortenedURL)
							sendCompleted(stream)
						}
					} else {
						sendError(stream, ConnectionError.StatusCode(jsonData["status_code"].int!))
					}
				} else {
					sendError(stream, ConnectionError.NoResponse((error!.localizedDescription)))
				}
				}.resume()

			return NopDisposable.instance
		}
	}
}
