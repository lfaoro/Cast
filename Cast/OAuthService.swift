//
//  OAuth.swift
//  Cast
//
//  Created by Leonardo on 13/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import SwiftyJSON

class OAuthService: NSObject {
    
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
