//
//  LFShortenURL.swift
//  Cast
//
//  Created by Leonardo on 25/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import SwiftyJSON

final class LFWebAPIs: NSObject {
    //---------------------------------------------------------------------------
    let session = NSURLSession.sharedSession()
    var textExcerpt: String?
    //---------------------------------------------------------------------------
    func share() {
        self.uploadTextData(app.pasteboard.extractData(), isPublic: false) {
            print($0)
            self.shortenURL($0) {
                app.pasteboard.copyToClipboard([$0])
                recentUploads[self.textExcerpt!] = String($0)
                app.statusBar.statusBarItem.menu = app.statusBar.createMenu()
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
                app.userNotification.pushNotification(error: "bit.ly Unreachable", description: error!.localizedDescription)
            }
            }.resume()
        //---------------------------------------------------------------------------
    }
    //---------------------------------------------------------------------------
    //TODO: Add GitHub login support
    func uploadTextData(string: String, fileName: String = "Casted.swift", isPublic: Bool = true, success: (String) -> () ) {
        print(__FUNCTION__)
        self.textExcerpt = extractExcerptFromString(string, length: 18)
        let githubAPIurl = NSURL(string: "https://api.github.com/gists")!
        let gitHubBodyDictionary = [
            "description": "Generated with Cast (www.castshare.io)",
            "public": true,
            "files":
                [fileName: ["content": string]
            ]
        ]
        let gitHubBodyJSON = JSON(gitHubBodyDictionary) // transforms Foundation object to JSON
        let request = NSMutableURLRequest(URL: githubAPIurl)
        //request.addValue(githubOAuthToken, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        do {
            request.HTTPBody = try gitHubBodyJSON.rawData()
        } catch {
            fatalError("Unable to convert JSON to NSData")
        }
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
                app.userNotification.pushNotification(error: "GitHub Unreachable", description: error!.localizedDescription)
            }
            }.resume()
        //---------------------------------------------------------------------------
    }
    //---------------------------------------------------------------------------
}
