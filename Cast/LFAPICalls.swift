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
        let githubAPIurl = "https://api.github.com/"
        let githubRequest = githubAPIurl + "gists"
        let url: NSURL! = NSURL(string: githubRequest)
        let request = NSMutableURLRequest(URL: url)
        request.addValue(githubOAuthToken, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        
        let content = [
            "description":"test description",
            "public":true,
            "files":
                ["testFiles.txt":
                    ["content": "test content of the Gist"
        ]]]
        
        let json = JSON(content)
        let data = try! NSJSONSerialization.dataWithJSONObject(json.object, options: [])
        request.HTTPBody = data

        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if let data = data, response = response {
//                print(response)
                
                let jsonObj = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                print(jsonObj["html_url"]!)
                
            } else {
                print(error)
            }
        }
        
        task.resume()
    }
}
