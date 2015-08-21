//
//  OAuth.swift
//  Cast
//
//  Created by Leonardo on 13/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift

import SwiftyJSON

public enum OAuthService: String {
    case GitHub = ""
}

public final class OAuthClient {
    let clientID: String
    let clientSecret: String
    let authURL: String
    let redirectURL: String
    let tokenURL: String
    
    
    //MARK:- INITIALISATION
    
    required public init(clientID: String,
        clientSecret: String,
        authURL: String,
        redirectURL: String,
        tokenURL: String) {
            
            self.clientID = clientID
            self.clientSecret = clientSecret
            self.authURL = authURL
            self.redirectURL = redirectURL
            self.tokenURL = tokenURL
    }
    
    convenience public init(clientID: String, clientSecret: String, service: OAuthService) {
        // get info from service and call super.init
        self.init(
            clientID: clientID,
            clientSecret: clientSecret,
            authURL: "https://github.com/login/oauth/authorize/", //info gathered from OAuthService
            redirectURL: "cast://oauth", // extract info from NSBundle Info.plist
            tokenURL: "https://github.com/login/oauth/access_token" //info gathered from OAuthService
        )
        
    }
    
    
    //MARK:- PUBLIC API
    
    public func authorize() -> Observable<String> {
        return empty()
    }
    
    public func revoke() -> Observable<String> {
        return empty()
    }
    
    public func getToken() -> String {
        return ""
    }
    
    
    //MARK:- HELPER FUNCTIONS
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
        //        eventManager = registerEventHandlerForURL(handler: self)
        
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
                //                exchangeCodeForAccessToken(code).on(next:).start() // how do I make sure that the token gets in that variable?
            }
        }
    }
    
    
    func exchangeCodeForAccessToken(code: String) -> Observable<String> {
        
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
        
        return create { stream in
            let session = NSURLSession.sharedSession()
            session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                if let data = data {
                    if let token = JSON(data: data)["access_token"].string {
                        sendNext(stream, token)
                        sendCompleted(stream)
                    } else {
                        sendError(stream, ConnectionError.InvalidData("No Token :((("))
                    }
                } else {
                    sendError(stream, ConnectionError.NoResponse(error!.localizedDescription))
                }
                }.resume()
            
            return NopDisposable.instance
        }
    }
    
}
