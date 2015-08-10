import Cocoa
import SwiftyJSON
import Quick
import Nimble

class GistServiceTests: QuickSpec {
  
  override func spec() {
    
    fdescribe("GistService wrapper") {
      
      context("Functions") {
        
        var gistService: GistService!
        var gistURL: NSURL?
        
        beforeEach {
          gistService = GistService()
        }
        
        
        it(".updateGist()") {
          gistURL = gistService.updateGist("testData")
          
          expect(gistURL).toNot(beNil())
          
          expect(gistService.gistID).toNot(beNil())
        }
        
        
        it(".reset()") {
          gistService.resetGist()
          
          expect(gistService.gistID).to(beNil())
        }
        
        fit(".postRequest()") {
          
          let returnValues =
          gistService.postRequest("Test Data", isUpdate: false, URL: gistService.gistAPIURL)
          
          expect(returnValues.URL).to(beAnInstanceOf(NSURL.self))
          
//          expect(gistService.session).to(beAnInstanceOf(NSURLSession.self))
          
        }
      }
      
      context("Upload was unsuccessful") {
      }
    }
  }
}