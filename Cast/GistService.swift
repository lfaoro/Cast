//
//  GistService.swift
//  Cast
//
//  Created by Leonardo on 08/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import SwiftyJSON
let servicesPath = NSBundle.mainBundle().pathForResource("Services", ofType: "plist")!
let webServices = JSON(NSDictionary(contentsOfFile: servicesPath)!)
//webServices["Gist"]["URL"].URL!
final class GistService {
  //---------------------------------------------------------------------------
  var userDefaults: NSUserDefaults
  var gistAPI: NSURL
  var gistID: String? {
    get {
      return userDefaults.objectForKey("gistID") as? String
    }
    set (id) {
      return userDefaults.setObject(id!, forKey: "gistID")
    }
  }
  //---------------------------------------------------------------------------
  init(apiURL: NSURL) {
    self.userDefaults = NSUserDefaults.standardUserDefaults()
    self.gistAPI = apiURL
  }
  //---------------------------------------------------------------------------
  func updateGist(data: String) -> NSURL? {
    if let gistID = gistID {
      print("Updating the Current Gist")
    } else {
      createGist(data)
    }
    return nil
  }
  //---------------------------------------------------------------------------
  func createGist(data: String) -> NSURL? {
    // call API and create a gist
    var gistURL: NSURL?
    postRequest(data, isUpdate: false, URL: gistAPI) { (URL, gistID) -> Void in
      self.gistID = gistID
      gistURL = URL
    }
    return gistURL
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
          let jsonData = JSON(data: data)
          if let url = jsonData["url"].URL, id = jsonData["id"].string {
            success(URL: url, gistID: id)
          } else {
            fatalError("No URL")
          }
        } else {
          print(error!.localizedDescription)
          app.userNotification.pushNotification(error: "Service Unreachable", description: error!.localizedDescription)
        }
        }.resume()
  }
}
