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
let gistAPIURL = webServices["Gist"]["URL"].URL!

/**
- TODO:
*/
public final class GistService {
  
  
  var session: NSURLSession
  let userDefaults: NSUserDefaults
  var gistAPIURL: NSURL
  let semaphore: dispatch_semaphore_t
  var gistID: String?
  //    get {
  //      return userDefaults.objectForKey("gistID") as? String
  //    }
  //    set (id) {
  //      return userDefaults.setObject(id!, forKey: "gistID")
  //    }
  
  
  init() {
    self.userDefaults = NSUserDefaults.standardUserDefaults()
    self.gistAPIURL = NSURL(string: "https://api.github.com/gists")!
    self.session = NSURLSession.sharedSession()
    self.semaphore = dispatch_semaphore_create(0)
  }
  
  convenience init(apiURL: String) {
    self.init()
    self.gistAPIURL = NSURL(string: apiURL)!
  }
  
  convenience init(session: NSURLSession) {
    self.init()
    self.session = session
  }
  
  
  func updateGist(data: String) -> NSURL {
    guard let gistID = gistID else { return createGist(data) }
    print("Updating the Current Gist: \(gistID)")
    //let (userGistURL, userGistID) = postRequest(data, isUpdate: true, URL: gistAPIURL)
    //return userGistURL
    return NSURL()
  }
  
  
  func createGist(data: String) -> NSURL {
    
    let (userGistURL, userGistID) = postRequest(data, isUpdate: false, URL: gistAPIURL)
    self.gistID = userGistID
    
    return userGistURL
  }
  
  
  func resetGist() -> Void {
    userDefaults.removeObjectForKey("gistID")
    //NOTE: Would like to return bool upon key removal completion
    //the API is not designed this way unfortunately...
  }
  
  
  func postRequest(content: String, isUpdate: Bool, URL: NSURL,
    isPublic: Bool = false, fileName: String = "Casted.swift") ->
    (URL: NSURL, gistID: String) {
      
      var userGistURL: NSURL!
      var userGistID: String!
      
      let gitHubHTTPBody = [
        "description": "Generated with Cast (cast.lfaoro.com)",
        "public": isPublic,
        "files": [fileName: ["content": content]]]
      
      let request = NSMutableURLRequest(URL: URL)
      
      request.HTTPMethod = "POST"
      request.HTTPBody = try! JSON(gitHubHTTPBody).rawData()
      
      
      session.dataTaskWithRequest(request) { (data, response, error) in
        if let data = data {
          print("we got data")
          let jsonData = JSON(data: data)
          if let url = jsonData["url"].URL, id = jsonData["id"].string {
            userGistURL = url
            userGistID = id
            dispatch_semaphore_signal(self.semaphore)
          } else {
            fatalError("No URL")
          }
        } else {
          print(error!.localizedDescription)
        }
        }.resume()
      
      
      dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
      return (userGistURL, userGistID)
  }
}
