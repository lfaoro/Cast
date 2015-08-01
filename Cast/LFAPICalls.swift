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
            print($0)
            self.shortenURL($0) {
                self.pasteboard.copyToClipboard([$0])
                recentUploads[String($0)] = String($0)
                let app = NSApp.delegate as! AppDelegate
                app.statusBar.statusBarItem.menu = app.statusBar.createMenu()
                print(recentUploads)
            }
        }
    }
    //---------------------------------------------------------------------------
    func shortenURL(URL: String, success:(NSURL)->()) {
        print(__FUNCTION__)
        let bitlyAPIurl = "https://api-ssl.bitly.com"
        let bitlyAPIshorten = bitlyAPIurl + "/v3/shorten?access_token=" + bitlyOAuth2Token + "&longUrl=" + URL
        let url = NSURL(string: bitlyAPIshorten)!
        //---------------------------------------------------------------------------
        session.dataTaskWithURL(url) { (data, response, error) in
            if let data = data {
                let jsonData = JSON(data: data)
                let statusCode = jsonData["status_code"].int
                if statusCode == 200 {
                    if let urlString = jsonData["data"]["url"].string {
                        if let url = NSURL(string: urlString) {
                            success(url)
                        }
                    }
                } else {
                    print(jsonData["status_code"].int)
                }
            } else {
                print(error?.localizedDescription)
                self.pasteboard.notification.pushNotification(error: "bit.ly Unreachable", description: error!.localizedDescription)
            }
            }.resume()
        //---------------------------------------------------------------------------
    }
    //---------------------------------------------------------------------------
    func uploadTextData(string: String, fileName: String = "Casted.swift", isPublic: Bool = true, success:(String)->()) {
        print(__FUNCTION__)
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
        let githubAPIurl = "https://api.github.com/gists"
        let url = NSURL(string: githubAPIurl)!
        let request = NSMutableURLRequest(URL: url)
        //request.addValue(githubOAuthToken, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        let data = try! json.rawData()
        request.HTTPBody = data
        //---------------------------------------------------------------------------
        session.dataTaskWithRequest(request) { (data, response, error) in
            if let data = data {
                let jsonData = JSON(data: data)
                if let url = jsonData["html_url"].string {
                    success(url)
                } else {
                    fatalError("No URL from GitHub")
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
