//
//  GistService.swift
//  Cast
//
//  Created by Leonardo on 08/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import SwiftyJSON

// Not sure if to structure data in a plist or not, evaluating...
let servicesPath = NSBundle.mainBundle().pathForResource("Services", ofType: "plist")!
let webServices = JSON(NSDictionary(contentsOfFile: servicesPath)!)
let gistAPIURL = webServices["Gist"]["URL"].URL!

enum ConnectionError: ErrorType {
  case Bad(String)
  case Worse(String)
  case Terrible(String)
}

/**
- NOTE: I know this should be Async, I wrote an Async version of the API
that used success: failure: return blocks but then I thought...
My App has no UI! It's a Status Agent and I don't like Void functions :P
- TODO: Add OAuth2 towards GitHub
- TODO: Investigate more about semaphores
*/
public final class GistService: NSObject {
  
  
  //MARK:- Properties
  var eventManager: NSAppleEventManager!
  var userDefaults: NSUserDefaults
  var gistAPIURL: NSURL
  var throwError: ConnectionError? // Eridius suggestion
  var gistID: String?
  //    get {
  //      return userDefaults.objectForKey("gistID") as? String
  //    }
  //    set (id) {
  //      return userDefaults.setObject(id!, forKey: "gistID")
  //    }
  
  
  //MARK:- Initialisation
  override init() {
    userDefaults = NSUserDefaults.standardUserDefaults()
    gistAPIURL = NSURL(string: "https://api.github.com/gists")!
    super.init()
    eventManager = registerEventHandlerForURL(handler: self)
  }
  
  convenience init(apiURL: String) {
    self.init()
    self.gistAPIURL = NSURL(string: apiURL)!
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
      
      let semaphore = dispatch_semaphore_create(0)
      let session = NSURLSession.sharedSession()
      session.dataTaskWithRequest(request) { (data, response, error) in
        
        if let data = data {
          
          let jsonData = JSON(data: data)
          
          if let url = jsonData["url"].URL, id = jsonData["id"].string {
            
            userGistURL = url
            userGistID = id
            
          } else {
            
            self.throwError = ConnectionError.Bad("URL or ID Invalid")
            
          }
          
        } else {
          
          print(error)
          self.throwError = ConnectionError.Bad(error!.localizedDescription)
          
        }
        
        dispatch_semaphore_signal(semaphore)
        
        }.resume()
      
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
      
      if let error = throwError {
        throw error
      }
      
      return (userGistURL, userGistID)
  }
  
  
}


//MARK:- OAuth2
extension GistService {
  
  
  func oauthRequest() -> Void {
    
    let oauthQuery = [
      NSURLQueryItem(name: "client_id", value: "ef09cfdbba0dfd807592"),
      NSURLQueryItem(name: "redirect_uri", value: "cast://oauth"),
      NSURLQueryItem(name: "scope", value: "gist")
      //      NSURLQueryItem(name: "state", value: "\(NSUUID().UUIDString)"),
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
    
    if let callback = event.descriptorForKeyword(AEEventClass(keyDirectObject))?.stringValue { // thank you mikeash!
      
      if let code = NSURLComponents(string: callback)?.queryItems?[0].value {
        
        if let token = exchangeCodeForAccessToken(code) {
          
          print(token)
          
        }
      }
    }
  }
  
  
  func exchangeCodeForAccessToken(code: String) -> String? {
    
    var token: String?
    
    let oauthQuery = [
      NSURLQueryItem(name: "client_id", value: "ef09cfdbba0dfd807592"),
      NSURLQueryItem(name: "client_secret", value: "ce7541f7a3d34c2ff5b20207a3036ce2ad811cc7"),
      NSURLQueryItem(name: "code", value: code),
      NSURLQueryItem(name: "redirect_uri", value: "cast://oauth"),
      //      NSURLQueryItem(name: "state", value: "\(NSUUID().UUIDString)"),
    ]
    
    let oauthComponents = NSURLComponents()
    oauthComponents.scheme = "https"
    oauthComponents.host = "github.com"
    oauthComponents.path = "/login/oauth/access_token"
    oauthComponents.queryItems = oauthQuery
    
    let request = NSMutableURLRequest(URL: oauthComponents.URL!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let semaphore = dispatch_semaphore_create(0)
    let session = NSURLSession.sharedSession()
    session.dataTaskWithRequest(request) { (data, response, error) -> Void in
      
      if let data = data {
        
        token = JSON(data: data)["access_token"].string
        
      } else {
        
        self.throwError = ConnectionError.Bad(error!.localizedDescription)
        
      }
      
      dispatch_semaphore_signal(semaphore)
      
      }.resume()
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    
    return token
    
  }
  
  
}
