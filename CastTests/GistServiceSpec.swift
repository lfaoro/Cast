//
//  GistServiceSpec.swift
//  XXXX
//
//  Created by Chris Patrick Schreiner on 09/08/15.
//  Copyright © 2015 Chris Patrick Schreiner. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SwiftyJSON

class MockedGistSpec: QuickSpec {
  
  private class MockedSession: NSURLSession {
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
      completionHandler(try! JSON(["html_url":"http://test.com","id":"123456790"]).rawData(),nil,nil)
      return MockedSessionDataTask()
    }
  }
  
  private class MockedSessionDataTask: NSURLSessionDataTask {
    override func resume() {}
  }
  
  override func spec() {
    describe("testing the gistservice class from Leo while Mocking the NSURLSession") {
      var g: GistService!
      
      beforeEach {
        let apiUrl = NSURL(string:"https://api.github.com/gists")! //doesn't matter what we have here
        g = GistService(api: apiUrl)
        g.session = MockedGistSpec.MockedSession() //setup a custom session
      }
      
      it("should have valid instance") {
        expect(g).toNot(beNil())
      }
      
      it("") {
        let dataToSend = "Some text to send as a gist"
        g.updateGist(dataToSend)
        
        expect(g.gistID).toEventually(equal("123456790"), timeout:1)
        expect(g.gistURL).toEventually(equal(NSURL(string:"http://test.com")),timeout:1)
      }
    }
  }
}

class GistSpec: QuickSpec {
  
  
  override func spec() {
    describe("testing the gistservice class from Leo") {
      
      var g: GistService!
      let dataToSend = "Some text to send as a gist"
      let updatedDataToSend = "Some updated text to send as a gist"
      
      beforeEach {
        let apiUrl = NSURL(string:"https://api.github.com/gists")!
        g = GistService(api: apiUrl)
      }
      
      it("should create an instance") {
        expect(g).toNot(beNil())
      }
      
      it("should set gistID to nil when resetting") {
        g.resetGist()
        expect(g.gistID).to(beNil())
      }
      
      it("should set gistID to a value when updating the gist") {
        g.updateGist(dataToSend)
        expect(g.gistID).toEventuallyNot(beNil(),timeout:3)
      }
      
      it("should update the gist without changing the gistID in an update") {
        g.updateGist(dataToSend)
        expect(g.gistID).toEventuallyNot(beNil(),timeout:3)
        
        let oldID = g.gistID
        
        g.updateGist(updatedDataToSend)
        expect(g.gistID).toEventually(equal(oldID),timeout:3)
      }
      
      fit("should update the gist and changing the gistID after a reset") {
        g.updateGist(dataToSend)
        expect(g.gistID).toEventuallyNot(beNil(),timeout:3)
        expect(g.gistURL).toEventuallyNot(beNil(),timeout:3)
        
        let oldID = g.gistID
        let oldURL = g.gistURL
        g.resetGist()
        
        g.updateGist(updatedDataToSend)
        expect(g.gistID).toEventuallyNot(equal(oldID),timeout:3)
        expect(g.gistURL).toEventuallyNot(equal(oldURL),timeout:3)
      }
    }
  }
}


import Cocoa
import SwiftyJSON


public class GistService {
  
  private func constructGistBody(data:String) throws -> NSData {
    let isPublic = false
    let filename = "dummy.swift"
    let description = "some description here"
    let json = JSON(["description":description,"public":isPublic,"files":[filename:["content":data]]])
    
    return try json.rawData()
  }
  
  private func createRequestWith(data:String) throws -> NSURLRequest {
    let githubAPIurl = NSURL(string: "https://api.github.com/gists")!
    let request = NSMutableURLRequest(URL: githubAPIurl)
    request.HTTPMethod = "POST"
    request.HTTPBody = try constructGistBody(data)
    return request
  }
  
  var session: NSURLSession = NSURLSession.sharedSession()
  var gistAPI: NSURL!
  var gistID: String?
  var gistURL: NSURL?
  
  public init(api: NSURL) {
    self.gistAPI = api
  }
  
  private func createGist(data: String){
    postRequest(data, isUpdate: false, URL: gistAPI, success: { URL, gistID in
      self.gistID = gistID
      self.gistURL = URL
    })
  }
  
  private func postRequest(content: String, isUpdate: Bool, URL: NSURL, isPublic: Bool = false, fileName: String = "Casted.swift", success: (URL: NSURL, gistID: String) -> Void) -> Void {
    
    do {
      let request = try createRequestWith(content)
      NSURLSession.sharedSession().dataTaskWithRequest(request)
      let d = session.dataTaskWithRequest(request) { (data, response, error) in
        if let data = data {
          let jsonData = JSON(data: data)
          if let url = jsonData["html_url"].URL, id = jsonData["id"].string {
            success(URL: url, gistID: id)
          } else {
            print(jsonData)
            fatalError("No URL") //TODO: the message is not correct
          }
        } else {
          print(error!.localizedDescription)
        }
      }
      d.resume()
      
    } catch {
      print(error)
    }
  }
  
  public func updateGist(data: String) {
    if gistID != nil {
      print("Updating the Current Gist")
    } else {
      createGist(data)
    }
  }
  
  public func resetGist() -> Void {
    gistID = nil
  }
}