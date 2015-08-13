//: Playground - noun: a place where people can play

import Cocoa
import SwiftyJSON
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely(true)

var str = "Hello, playground"

func exchangeCodeForAccessToken(code: String) -> String {
  
  let session = NSURLSession.sharedSession()
  
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

exchangeCodeForAccessToken(<#T##code: String##String#>)
  