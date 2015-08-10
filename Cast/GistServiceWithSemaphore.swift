//
//  GistService.swift
//  Cast
//
//  Created by Leonardo on 08/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import SwiftyJSON

/**
- TODO: Refactor the Async operations with GCD
*/
public final class GistService {
  //---------------------------------------------------------------------------
  var session: NSURLSession
  var userDefaults: NSUserDefaults
  var gistAPIURL: NSURL!
  var gistID: String?
  var semaphore: dispatch_semaphore_t
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
    self.session = NSURLSession.sharedSession()
    self.semaphore = dispatch_semaphore_create(0)
  }
  //---------------------------------------------------------------------------
  func updateGist(data: String, success: (URL: NSURL) -> Void) -> Void {
    if let gistID = gistID {
      print("Updating the Current Gist")
      success(URL: NSURL())
    } else {
      print(createGist(data))
    }
  }
  //---------------------------------------------------------------------------
  func createGist(data: String) -> NSURL {
    // call API and create a gist
    var gistLinkURL: NSURL?
    postRequest(data, isUpdate: false, URL: gistAPIURL) { (URL1, gistID) -> Void in
      self.gistID = gistID
      gistLinkURL = URL1
      print(gistLinkURL)
      dispatch_semaphore_signal(self.semaphore)
    }
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
    return gistLinkURL!
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
