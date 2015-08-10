//
//  LFShortenURL.swift
//  Cast
//
//  Created by Leonardo on 25/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa
import SwiftyJSON

final class WebAPIs: NSObject {
  //---------------------------------------------------------------------------
  let session = NSURLSession.sharedSession()
  var textExcerpt: String?
  //---------------------------------------------------------------------------
  func share(pasteboard: PasteboardController) throws -> () {
    startUpload(try pasteboard.extractData(), isPublic: false) {
      print($0)
      self.startShorten($0) {
        pasteboard.copyToClipboard([$0])
        recentUploads[self.textExcerpt!] = String($0)
        app.updateMenu()
      }
    }
  }
  func shareGist(pastedboard: PasteboardController) {
    
  }
  //---------------------------------------------------------------------------
  /**
  Takes a URL as a String and processes it asynchronously using a URL shortening
  service.
  - parameter URL: the URI to shorten as a String object
  - parameter success: Closure of the async call to the shorten URI service
  - returns: a URL from the success Block
  - TODO: add more shortening services
  - TODO: retrieve service from options
  */
  func startShorten(URL: String, success:(NSURL) -> ()) {
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
            success(NSURL(string: urlString)!)
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
  /**
  Takes a URL as a String and processes it asynchronously using a URL shortening
  service.
  - parameter URL: the URI to shorten as a String object
  - parameter success: Closure of the async call to the shorten URI service
  - returns: a URL from the success Block
  - TODO: add more data upload services
  - TODO: retrieve correct service from options (maybe calling a function)
  - TODO: support for AnyObject
  */
  func startUpload(data: PasteboardData, fileName: String = "Casted.swift", isPublic: Bool = true, success: (String) -> ()) {
    //---------------------------------------------------------------------------
    var jsonBody: JSON!
    var request: NSMutableURLRequest!
    //---------------------------------------------------------------------------
    switch data {
      //---------------------------------------------------------------------------
    case .Text(let data):
      self.textExcerpt = extractExcerptFromString(data , length: 18)
      let githubAPIurl = NSURL(string: "https://api.github.com/gists")!
      let gitHubBodyDictionary = [
        "description": "Generated with Cast (www.castshare.io)",
        "public": isPublic,
        "files":
          [fileName: ["content": data]
        ]
      ]
      jsonBody = JSON(gitHubBodyDictionary) // transforms Foundation object to JSON
      request = NSMutableURLRequest(URL: githubAPIurl)
      //request.addValue(githubOAuthToken, forHTTPHeaderField: "Authorization")
      request.HTTPMethod = "POST"
      do {
        request.HTTPBody = try jsonBody.rawData()
      } catch {
        fatalError("Unable to convert JSON to NSData")
      }
      //---------------------------------------------------------------------------
    case .Image(_):
      app.userNotification.pushNotification(error: "It's an image!")
      return
      //---------------------------------------------------------------------------
    default: app.userNotification.pushNotification(error: "Service Unreachable", description: "Your pasteboard contains invalid data.")
    }
    //---------------------------------------------------------------------------
    session.dataTaskWithRequest(request) { (data, response, error) in
      if let data = data {
        let jsonData = JSON(data: data)
        if let url = jsonData["html_url"].string {
          success(url)
        } else {
          fatalError("No URL")
        }
      } else {
        print(error!.localizedDescription)
        app.userNotification.pushNotification(error: "Service Unreachable", description: error!.localizedDescription)
      }
      }.resume()
    //---------------------------------------------------------------------------
  }
  //---------------------------------------------------------------------------
}
