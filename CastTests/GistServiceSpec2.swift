import Cocoa
import SwiftyJSON
import Quick
import Nimble

class GistServiceTests: QuickSpec {
  
  override func spec() {
    
    fdescribe("uploadGist") {
      
      context("Upload was successful") {
        var gistService: GistService!
        var gistProperties: (NSURL,String)?
        beforeEach {
          gistService = GistService()
        }
        
        it("URL not NIL") {
          gistProperties = gistService.updateGist("testData")
          expect(gistProperties).toNot(beNil())
          //          expect(1) == 0
        }
      }
      
      context("Upload was unsuccessful") {
      }
    }
  }
}