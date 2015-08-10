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
        g = GistService(apiURL: apiUrl)
        g.session = MockedGistSpec.MockedSession() //setup a custom session
      }
      
      it("should have valid instance") {
        expect(g).toNot(beNil())
      }
      
      it("") {
        let dataToSend = "Some text to send as a gist"
        g.updateGist(dataToSend, success: { (URL) -> Void in
          g.gistAPIURL = URL
        })
        
        expect(g.gistID).toEventually(equal("123456790"), timeout:1)
        expect(g.gistAPIURL).toEventually(equal(NSURL(string:"http://test.com")),timeout:1)
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
        g = GistService(apiURL: apiUrl)
      }
      
      it("should create an instance") {
        expect(g).toNot(beNil())
      }
      
      it("should set gistID to nil when resetting") {
        g.resetGist()
        expect(g.gistID).to(beNil())
      }
      
      it("should set gistID to a value when updating the gist") {
        g.updateGist(dataToSend, success: { (URL) -> Void in
          
        })
        expect(g.gistID).toEventuallyNot(beNil(),timeout:3)
      }
      
      it("should update the gist without changing the gistID in an update") {
//        g.updateGist(dataToSend)
        expect(g.gistID).toEventuallyNot(beNil(),timeout:3)
        
        let oldID = g.gistID
        
//        g.updateGist(updatedDataToSend)
        expect(g.gistID).toEventually(equal(oldID),timeout:3)
      }
      
      fit("should update the gist and changing the gistID after a reset") {
//        g.updateGist(dataToSend)
        expect(g.gistID).toEventuallyNot(beNil(),timeout:3)
        expect(g.gistAPIURL).toEventuallyNot(beNil(),timeout:3)
        
        let oldID = g.gistID
        let oldURL = g.gistAPIURL
        g.resetGist()
        
//        g.updateGist(updatedDataToSend)
        expect(g.gistID).toEventuallyNot(equal(oldID),timeout:3)
        expect(g.gistAPIURL).toEventuallyNot(equal(oldURL),timeout:3)
      }
    }
  }
}