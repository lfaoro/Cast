//
//  GistService.swift
//  Cast
//
//  Created by Leonardo on 08/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

//    get {
//      return userDefaults.objectForKey("gistID") as? String
//    }
//    set (id) {
//      return userDefaults.setObject(id!, forKey: "gistID")
//    }

import Cocoa
import ReactiveCocoa
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
- TODO: Add OAuth2 towards GitHub as a protocol
- TODO: Make it RAC
- TODO: Store gistID in NSUserDefaults
*/
public final class GistService: NSObject {
    
    //MARK:- Properties
    var userDefaults: NSUserDefaults
    var gistAPIURL: NSURL
    var gistID: String?
    
    
    //MARK:- Initialisation
    
    override init() {
        userDefaults = NSUserDefaults.standardUserDefaults()
        gistAPIURL = NSURL(string: "https://api.github.com/gists")!
        super.init()
    }
    
    convenience init(apiURL: String) {
        self.init()
        self.gistAPIURL = NSURL(string: apiURL)!
    }
    
    
    //MARK:- Public API
    
    func resetGist() -> Bool {
        //    userDefaults.removeObjectForKey("gistID")
        self.gistID = nil
        
        return !gistUpdate()
    }
    
    func setGist(content content: String,
        isPublic: Bool = false, fileName: String = "Casted.swift") // defaults
        -> SignalProducer<(URL: String, gistID: String), ConnectionError> {
            
            return SignalProducer {sink, disp in
                
                let gitHubHTTPBody = [
                    "description": "Generated with Cast (cast.lfaoro.com)",
                    "public": isPublic,
                    "files": [fileName: ["content": content]],
                ]
                
                let request: NSMutableURLRequest
                if self.gistUpdate() {
                    let updateURL = NSURL(string: self.gistAPIURL.path! + self.gistID!)!
                    request = NSMutableURLRequest(URL: updateURL)
                    request.HTTPMethod = "PATCH"
                } else {
                    request = NSMutableURLRequest(URL: self.gistAPIURL)
                    request.HTTPMethod = "POST"
                    request.HTTPBody = try! JSON(gitHubHTTPBody).rawData()
                }
                
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { (data, response, error) in
                    if let data = data {
                        let jsonData = JSON(data: data)
                        if let url = jsonData["html_url"].string, id = jsonData["id"].string {
                            sendNext(sink, (url, id))
                            sendCompleted(sink)
                        } else {
                            sendError(sink, ConnectionError.Bad("URL or ID Invalid"))
                        }
                    } else {
                        sendError(sink, ConnectionError.Worse(error!.localizedDescription))
                    }
                }
                task.resume()
            }
    }
    
    
    //MARK:- Helper functions
    
    func gistUpdate() -> Bool {
        guard let _ = self.gistID else { return false }
        return true
    }
}