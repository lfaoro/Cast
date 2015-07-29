//
//  LFShortenURL.swift
//  Cast
//
//  Created by Leonardo on 25/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import SwiftyJSON

final class LFAPICalls: NSObject {
    //---------------------------------------------------------------------------
    let session = NSURLSession.sharedSession()
    //---------------------------------------------------------------------------
    func shortenURL(URL: String, successBlock:(NSURL?)->(), failureBlock:(Int)->() = {_ in }) {
        /// Bit.ly parameters
        let bitlyAPIurl = "https://api-ssl.bitly.com"
        let bitlyAPIshorten = bitlyAPIurl + "/v3/shorten?access_token=" + bitlyOAuth2Token + "&longUrl=" + URL
        let url: NSURL! = NSURL(string: bitlyAPIshorten)
        //---------------------------------------------------------------------------
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
        //---------------------------------------------------------------------------
        task.resume()
    }
    //---------------------------------------------------------------------------
    func uploadString(string: String, fileName: String = "Casted.swift", isPublic: Bool = true) {
        //let clipboardContent = "//Generated with Cast\r"
        let content = [
            "description":"Generated with Cast (www.castapp.io)",
            "public":true,
            "files":
                [fileName:
                    ["content": string]
            ]
        ]
        let json = JSON(content)
        print(json)
        let data = try! NSJSONSerialization.dataWithJSONObject(json.object, options: [])
        let githubAPIurl = "https://api.github.com/gists"
        let url: NSURL! = NSURL(string: githubAPIurl)
        let request = NSMutableURLRequest(URL: url)
        //request.addValue(githubOAuthToken, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        request.HTTPBody = data
        //---------------------------------------------------------------------------
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if let data = data, _ = response {
                //print(response)
                
                let jsonObj = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                if let url = jsonObj["html_url"] as? String {
                    self.shortenURL(url, successBlock: { (url) -> () in
                        if let url = url {
                            print(url)
                            NSWorkspace.sharedWorkspace().openURL(url)
                        }
                    })
                }
                
            } else {
                print(error)
            }
        }
        //---------------------------------------------------------------------------
        task.resume()
    }
    //---------------------------------------------------------------------------
}
