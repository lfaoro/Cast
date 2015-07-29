//
//  LFShortenURL.swift
//  Cast
//
//  Created by Leonardo on 25/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa


class LFAPICalls: NSObject {

	let session = NSURLSession.sharedSession()

	func shortenURL(URL: String, successBlock:(NSURL?)->(), failureBlock:(Int)->() = {_ in }) {

		/// Bit.ly parameters
		let bitlyOAuth2Token = "64192e52f6c12c89942e88ad142796d7caec90cd"
		let bitlyAPIurl = "https://api-ssl.bitly.com"
		let bitlyAPIshorten = bitlyAPIurl + "/v3/shorten?access_token=" + bitlyOAuth2Token + "&longUrl=" + URL
		let url: NSURL! = NSURL(string: bitlyAPIshorten)


		let task = session.dataTaskWithURL(url) { (data, response, error) in
			if let data = data {
				let jsonObj = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
				let statusCode = jsonObj["status_code"]! as! Int
				if statusCode == 200 {
					if let urlString = jsonObj["data"]!["url"]! as? String {
						if let url = NSURL(string: urlString) {
							successBlock(url)
						}
					}
				} else {
					failureBlock(statusCode)
				}
			} else {
				print(error)
			}
		}
		task.resume()
	}
    
    func uploadString() {
        let oauth = "https://github.com/login/oauth/authorize?client_id=...&redirect_uri=http://www.example.com/oauth_redirect"
        let url = NSURL(string: oauth)!
        NSWorkspace.sharedWorkspace().openURL(url)
    }
}
