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

enum AsyncErrors: ErrorType {
  case Bad(String)
  case Worse(String)
  case Terrible(String)
  case InvalidJSONData(String)
  case ConnectionFailure(String)
}
/**
- TODO: Implement update API
*/
public final class GistService: NSObject, NSURLSessionTaskDelegate {
  
  
  var session: NSURLSession
  let userDefaults: NSUserDefaults
  var gistAPIURL: String
  let semaphore: dispatch_semaphore_t
  var throwError: AsyncErrors? // Eridius suggestion
  var oauthToken: String?
  var gistID: String?
  //    get {
  //      return userDefaults.objectForKey("gistID") as? String
  //    }
  //    set (id) {
  //      return userDefaults.setObject(id!, forKey: "gistID")
  //    }
  
  
  init() {
    self.userDefaults = NSUserDefaults.standardUserDefaults()
    self.gistAPIURL = "https://api.github.com/gists"
    self.session = NSURLSession.sharedSession()
    self.semaphore = dispatch_semaphore_create(0)
  }
  
  convenience init(apiURL: String) {
    self.init()
    self.gistAPIURL = apiURL
  }
  
  convenience init(session: NSURLSession) {
    self.init()
    self.session = session
  }
  
  
  func updateGist(data: String) throws -> NSURL {
    guard let gistID = gistID else { return try createGist(data) }
    print("Updating the Current Gist: \(gistID)")
    let (userGistURL, _) = try postRequest(data, isUpdate: true, URL: gistAPIURL)
    return userGistURL
  }
  
  
  func createGist(data: String) throws -> NSURL {
    
    let (userGistURL, userGistID) = try postRequest(data, isUpdate: false, URL: gistAPIURL)
    if oauthToken != nil {
      self.gistID = userGistID
    }
    
    return userGistURL
  }
  
  
  func resetGist() -> Void {
    //    userDefaults.removeObjectForKey("gistID")
    self.gistID = nil
    //NOTE: Would like to return bool upon key removal completion
    //the API is not designed this way unfortunately...
  }
  
  func requestOAuth(success: (oauthToken: String) -> Void) {
    let githubHTTPBody = [
      "client_id": "ef09cfdbba0dfd807592",
      "redirect_uri": "cast://",
      "scope": "gist",
      "state": "\(NSUUID().UUIDString)"
    ]
    
    let request = NSMutableURLRequest(URL: NSURL(string: "https://github.com/login/oauth/authorize")!)
    request.HTTPMethod = "GET"
    request.HTTPBody = try! JSON(githubHTTPBody).rawData()
    
    session.dataTaskWithRequest(request) { (data, response, error) in
      if let response = response {
        print(response)
        success(oauthToken: "test")
      } else {
        print(error!)
      }
    }.resume()
  }
  
 public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
    print("redirect")
  }
  
  func postRequest(content: String, isUpdate: Bool, URL: String,
    isPublic: Bool = true, fileName: String = "Casted.swift") throws ->
    (URL: NSURL, gistID: String) {
      
      var userGistURL: NSURL!
      var userGistID: String!
      let gitHubHTTPBody = [
        "description": "Generated with Cast (cast.lfaoro.com)",
        "public": isPublic,
        "files": [fileName: ["content": content]]]
      
      let request: NSMutableURLRequest
      
      if isUpdate {
        let updateURL = NSURL(string: "\(URL)/\(gistID!)")!
        request = NSMutableURLRequest(URL: updateURL)
        request.HTTPMethod = "PATCH"
      } else {
        request = NSMutableURLRequest(URL: NSURL(string: URL)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = try! JSON(gitHubHTTPBody).rawData()
      }
      
      session.dataTaskWithRequest(request) { (data, response, error) in
        
        if let data = data {
          let jsonData = JSON(data: data)
          print(jsonData)
          
          if let url = jsonData["html_url"].URL, id = jsonData["id"].string {
            userGistURL = url
            userGistID = id
            dispatch_semaphore_signal(self.semaphore)
          } else {
            self.throwError = AsyncErrors.InvalidJSONData(jsonData["message"].string!)
            dispatch_semaphore_signal(self.semaphore)
          }
          
        } else {
          print(error)
          self.throwError = AsyncErrors.ConnectionFailure(error!.localizedDescription)
          dispatch_semaphore_signal(self.semaphore)
        }
        }.resume()
      
      dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
      
      if let error = throwError {
        throw error
      }
      
      return (userGistURL, userGistID)
  }
}

let gistServ = GistService()
gistServ.requestOAuth { (oauthToken) -> Void in
  print("success")
}
//do {
//  try gistServ.updateGist("test data")
//} catch {
//  print(error)
//}
//








