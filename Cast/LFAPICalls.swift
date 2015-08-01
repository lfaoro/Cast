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
    let pasteboard = LFPasteboard()
    //---------------------------------------------------------------------------
    func share() {
        self.uploadTextData(pasteboard.extractData()) {
            self.shortenURL($0) {
                self.pasteboard.copyToClipboard([$0])
                recentUploads[String($0)] = String($0)
                appDelegate.statusBar.statusBarItem.menu?.update()
                print(recentUploads)
            }
        }
    }
    //---------------------------------------------------------------------------
    func shortenURL(URL: NSURL, success:(NSURL)->()) {
        /// Bit.ly parameters
        let bitlyAPIurl = "https://api-ssl.bitly.com"
        let bitlyAPIshorten = bitlyAPIurl + "/v3/shorten?access_token=" + bitlyOAuth2Token + "&longUrl=" + String(URL)
        let url: NSURL! = NSURL(string: bitlyAPIshorten)
        //---------------------------------------------------------------------------
        session.dataTaskWithURL(url) { (data, response, error) in
            if let data = data {
                //FIXME: Catch the eventual Throw for shortenURL
                let jsonObj = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                let statusCode = jsonObj["status_code"]! as! Int
                if statusCode == 200 {
                    if let urlString = jsonObj["data"]!["url"]! as? String {
                        if let url = NSURL(string: urlString) {
                            success(url)
                        }
                    }
                }
            } else {
                print(error?.localizedDescription)
                self.pasteboard.notification.pushNotification(error: "bit.ly Unreachable", description: error!.localizedDescription)
            }
            }.resume()
        //---------------------------------------------------------------------------
    }
    //---------------------------------------------------------------------------
    func uploadTextData(string: String, fileName: String = "Casted.swift", isPublic: Bool = true, success:(NSURL)->()) {
        //TODO: Add GitHub login support
        let content = [
            "description": "Generated with Cast (www.castshare.io)",
            "public": true,
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
        session.dataTaskWithRequest(request) { (data, response, error) in
            if let data = data {
                //FIXME: Catch the eventual throw for uploadString
                let jsonObj = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                if let url = jsonObj["html_url"] as? NSURL {
                    success(url)
                }
            } else {
                print(error!.localizedDescription)
                self.pasteboard.notification.pushNotification(error: "GitHub Unreachable", description: error!.localizedDescription)
            }
            }.resume()
        //---------------------------------------------------------------------------
    }
    //---------------------------------------------------------------------------
}
