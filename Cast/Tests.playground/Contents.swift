//: Playground - noun: a place where people can play

import Cocoa
import SwiftyJSON
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely(true)

var str = "Hello, playground"


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
  request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
  
  
  let session = NSURLSession.sharedSession()
  session.dataTaskWithRequest(request) { (data, response, error) in
    if let response = response {
      print(response)
      success(oauthToken: "test")
    } else {
      print(error!)
    }
    }.resume()
}

requestOAuth { (oauthToken) -> Void in
  "success"
}