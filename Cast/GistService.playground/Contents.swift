//: Playground - noun: a place where people can play

import Cocoa
import SwiftyJSON
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely()

final class GistService {
  //---------------------------------------------------------------------------
  var userDefaults: NSUserDefaults
  var gistAPI: NSURL
  var gistID: String? = nil
  var gistURL: NSURL?
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
      return createGist(data)
    }
    return nil
  }
  //---------------------------------------------------------------------------
  func createGist(data: String) -> NSURL? {
    print(__FUNCTION__)
    var gistURL: NSURL?
    postRequest(data, isUpdate: false, URL: gistAPI) {
      print($1)
      self.gistID = $1
      self.gistURL = $0
      print(self.gistURL)
    }
    return self.gistURL
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
            print("we got data")
            success(URL: url, gistID: id)
          } else {
            fatalError("No URL")
          }
        } else {
          print(error!.localizedDescription)
        }
        }.resume()
  }
}

let gistService = GistService(apiURL: NSURL(string: "https://api.github.com/gists")!)
gistService.updateGist("Yalla")

"ok"

