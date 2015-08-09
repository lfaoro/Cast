//: Playground - noun: a place where people can play

import Cocoa
import SwiftyJSON
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely()

protocol GistServiceDelegate {
  var userGistURL: NSURL {get set}
  var userGistID: String {get set}
  func getGistData(userGistURL: NSURL, userGistID: String) -> (userGistURL: NSURL, userGistID: String)
}

final class GistService {
  //---------------------------------------------------------------------------
  var delegate: GistServiceDelegate?
  var userDefaults: NSUserDefaults
  var gistAPI: NSURL
  var gistID: String? = nil
  //---------------------------------------------------------------------------
  init(apiURL: NSURL) {
    self.userDefaults = NSUserDefaults.standardUserDefaults()
    self.gistAPI = apiURL
  }
  //---------------------------------------------------------------------------
  func updateGist(data: String) -> Void {
    if let gistID = gistID {
      print("Updating the Current Gist")
    } else {
      createGist(data)
    }
  }
  //---------------------------------------------------------------------------
  func createGist(data: String) -> Void {
    print(__FUNCTION__)
    var gistURL: NSURL?
    
  }
  //---------------------------------------------------------------------------
  func resetGist() -> Void {
    userDefaults.removeObjectForKey("gistID")
    //NOTE: Would like to return bool upon key removal completion
    //the API is not designed this way unfortunately...
  }
  //---------------------------------------------------------------------------
  func postRequest(content: String, isUpdate: Bool, URL: NSURL,
    isPublic: Bool = false, fileName: String = "Casted.swift") { //Default values
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
            self.delegate?.userGistURL = url
            self.delegate?.userGistID = id
            self.delegate?.getGistData(url, userGistID: id)
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

