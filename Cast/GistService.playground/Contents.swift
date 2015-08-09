//
//  GistService.swift
//  Cast
//
//  Created by Leonardo on 08/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import SwiftyJSON
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely(true)
/**
- TODO: Refactor the Async operations with PromiseKit
*/
final class GistService {
  //---------------------------------------------------------------------------
  var userDefaults: NSUserDefaults
  var gistAPIURL: NSURL!
  var gistID: String? = nil
//    get {
//      return userDefaults.objectForKey("gistID") as? String
//    }
//    set (id) {
//      return userDefaults.setObject(id!, forKey: "gistID")
//    }
  //---------------------------------------------------------------------------
  init(apiURL: NSURL) {
    self.userDefaults = NSUserDefaults.standardUserDefaults()
    self.gistAPIURL = apiURL
  }
  //---------------------------------------------------------------------------
  func updateGist(data: String, success: (URL: NSURL) -> Void) -> Void {
    if let gistID = gistID {
      print("Updating the Current Gist")
      success(URL: NSURL())
    } else {
      createGist(data, success: { (URL2) -> Void in
        success(URL: URL2)
      })
    }
  }
  //---------------------------------------------------------------------------
  func createGist(data: String, success: (URL: NSURL) -> Void) -> Void {
    // call API and create a gist
    postRequest(data, isUpdate: false, URL: gistAPIURL) { (URL1, gistID) -> Void in
      self.gistID = gistID
      success(URL: URL1)
    }
  }
  //---------------------------------------------------------------------------
  func resetGist() -> Void {
    userDefaults.removeObjectForKey("gistID")
    //NOTE: Would like to return bool upon key removal completion
    //the API is not designed this way unfortunately...
  }
  //---------------------------------------------------------------------------
  func postRequest(content: String, isUpdate: Bool, URL: NSURL,
    isPublic: Bool = false, fileName: String = "Casted.swift",
    success: (URL: NSURL, gistID: String) -> Void) -> Void {
      //---------------------------------------------------------------------------
      let gitHubHTTPBody = [
        "description": "Generated with Cast (cast.lfaoro.com)",
        "public": isPublic,
        "files": [fileName: ["content": content]]]
      //---------------------------------------------------------------------------
      let session = NSURLSession.sharedSession()
      let request = NSMutableURLRequest(URL: URL)
      //---------------------------------------------------------------------------
      request.HTTPMethod = "POST"
      request.HTTPBody = try! JSON(gitHubHTTPBody).rawData()
      session.dataTaskWithRequest(request) { (data, response, error) in
        if let data = data {
          print("we got data")
          let jsonData = JSON(data: data)
          if let url = jsonData["url"].URL, id = jsonData["id"].string {
            success(URL: url, gistID: id)
          } else {
            fatalError("No URL")
          }
        } else {
          print(error!.localizedDescription)
        }
        }.resume()
  }
}

let gistServ = GistService(apiURL: NSURL(string: "https://api.github.com/gists")!)

gistServ.updateGist("testdata") { (URL3) -> Void in
  print("what? \(URL3)")
}









