import Cocoa
import RxSwift
import RxCocoa
import SwiftyJSON


public class ShortenClient {


	public class func shortenWithIsGd(URL URL: NSURL) -> Observable<String?> {
		let session = NSURLSession.sharedSession()
		let shorten = NSURL(string: "https://is.gd/create.php?format=json&url=" + URL.absoluteString)!

		return session.rx_JSON(shorten)
			.debug("shorten")
			.retry(3)
			.map { $0["shorturl"] as? String }
	}

	public class func shortenWithHive(URL URL: NSURL) -> Observable<String?> {
		let hiveAPIURL = "https://hive.am/api?api=spublic&url=\(URL.absoluteString)" +
						 "&description=cast.lfaoro.com&type=DIRECT"

		let session = NSURLSession.sharedSession()
		let shorten = NSURL(string: hiveAPIURL)!

		return session.rx_JSON(shorten)
			.debug("shorten Hive")
			.retry(3)
			.map { $0["short"] as? String }
	}

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
