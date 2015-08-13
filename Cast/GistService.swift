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

enum ConnectionError: ErrorType {
  case Bad(String)
  case Worse(String)
  case Terrible(String)
}

/**
- TODO: Implement update API
*/
public final class GistService {
  
  
  //MARK:- Properties
  var session: NSURLSession
  let userDefaults: NSUserDefaults
  var gistAPIURL: NSURL
  let semaphore: dispatch_semaphore_t
  var throwError: ConnectionError? // Eridius suggestion
  var gistID: String?
  //    get {
  //      return userDefaults.objectForKey("gistID") as? String
  //    }
  //    set (id) {
  //      return userDefaults.setObject(id!, forKey: "gistID")
  //    }
  
  
  //MARK:- Initialisation
  init() {
    self.userDefaults = NSUserDefaults.standardUserDefaults()
    self.gistAPIURL = NSURL(string: "https://api.github.com/gists")!
    self.session = NSURLSession.sharedSession()
    self.semaphore = dispatch_semaphore_create(0)
    self.eventManager = registerEventHandlerForURL(handler: self)
  }
  
  convenience init(apiURL: String) {
    self.init()
    self.gistAPIURL = NSURL(string: apiURL)!
  }
  
  convenience init(session: NSURLSession) {
    self.init()
    self.session = session
  }
  
  
  //MARK:- Public API
  func updateGist(data: String) throws -> NSURL {
    guard let gistID = gistID else { return try createGist(data) }
    print("Updating the Current Gist: \(gistID)")
    let (userGistURL, _) = try postRequest(data, isUpdate: true, URL: gistAPIURL)
    return userGistURL
  }
  
  func resetGist() -> Void {
    //    userDefaults.removeObjectForKey("gistID")
    self.gistID = nil
    //NOTE: Would like to return bool upon key removal completion
    //the API is not designed this way unfortunately...
  }
  
  
  //MARK:- Helper functions
  func createGist(data: String) throws -> NSURL {
    
    let (userGistURL, userGistID) = try postRequest(data, isUpdate: false, URL: gistAPIURL)
    self.gistID = userGistID
    
    return userGistURL
  }
  
  func postRequest(content: String, isUpdate: Bool, URL: NSURL,
    isPublic: Bool = false, fileName: String = "Casted.swift") throws ->
    (URL: NSURL, gistID: String) {
      
      var userGistURL: NSURL!
      var userGistID: String!
      let gitHubHTTPBody = [
        "description": "Generated with Cast (cast.lfaoro.com)",
        "public": isPublic,
        "files": [fileName: ["content": content]]]
      
      let request: NSMutableURLRequest
      
      if isUpdate {
        let updateURL = NSURL(string: URL.path! + gistID!)!
        request = NSMutableURLRequest(URL: updateURL)
        request.HTTPMethod = "PATCH"
      } else {
        request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"
        request.HTTPBody = try! JSON(gitHubHTTPBody).rawData()
      }
      
      session.dataTaskWithRequest(request) { (data, response, error) in
        
        if let data = data {
          let jsonData = JSON(data: data)
          
          if let url = jsonData["url"].URL, id = jsonData["id"].string {
            userGistURL = url
            userGistID = id
            dispatch_semaphore_signal(self.semaphore)
          } else {
            self.throwError = ConnectionError.Bad("URL or ID Invalid")
            dispatch_semaphore_signal(self.semaphore)
          }
          
          
        } else {
          print(error)
          self.throwError = ConnectionError.Bad(error!.localizedDescription)
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


//MARK:- OAuth2
extension GistService {
  
  
  lazy var eventManager: NSAppleEventManager?
  
  
  func githubOAuthRequest() -> Void {
    
    let oauthQuery = [
      NSURLQueryItem(name: "client_id", value: "ef09cfdbba0dfd807592"),
      NSURLQueryItem(name: "redirect_uri", value: "cast://oauth"),
      NSURLQueryItem(name: "scope", value: "gist"),
      NSURLQueryItem(name: "state", value: "\(NSUUID().UUIDString)"),
    ]
    
    let oauthComponents = NSURLComponents()
    oauthComponents.scheme = "https"
    oauthComponents.host = "github.com"
    oauthComponents.path = "/login/oauth/authorize/"
    oauthComponents.queryItems = oauthQuery
    
    
    // Register for callback from GitHub
    eventManager = registerEventHandlerForURL(handler: self)
    
    
    NSWorkspace.sharedWorkspace().openURL(oauthComponents.URL!)
    
  }
  
  
  func registerEventHandlerForURL(handler object: AnyObject) -> NSAppleEventManager {
    let eventManager: NSAppleEventManager = NSAppleEventManager.sharedAppleEventManager()
    eventManager.setEventHandler(object,
      andSelector: "handleURLEvent:",
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventClass(kAEGetURL))
    return eventManager
  }
  
  func handleURLEvent(event: NSAppleEventDescriptor) -> Void {
    if let callback = event.descriptorForKeyword(AEEventClass(keyDirectObject))?.stringValue {
      if let code = NSURLComponents(string: callback)?.queryItems?[0].value {
        let token = exchangeCodeForAccessToken(code)
        //store access token inside the keychain
      }
    }
  }
  
  func exchangeCodeForAccessToken(code: String) -> String {
    
    let oauthQuery = [
      NSURLQueryItem(name: "client_id", value: "ef09cfdbba0dfd807592"),
      NSURLQueryItem(name: "redirect_uri", value: "cast://oauth"),
      NSURLQueryItem(name: "scope", value: "gist"),
      NSURLQueryItem(name: "state", value: "\(NSUUID().UUIDString)"),
      NSURLQueryItem(name: "code", value: code)
    ]
    
    let oauthComponents = NSURLComponents()
    oauthComponents.scheme = "https"
    oauthComponents.host = "github.com"
    oauthComponents.path = "/login/oauth/access_token"
    oauthComponents.queryItems = oauthQuery
    
    session.dataTaskWithURL(oauthComponents.URL!) { (data, response, error) -> Void in
      if let data = data, response = response {
        print(response)
        print(JSON(data).stringValue)
      } else {
        print(error!.localizedDescription)
      }
    }
    
    return ""
    
  }
  
  
}
