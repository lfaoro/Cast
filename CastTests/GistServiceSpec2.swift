import Cocoa
import SwiftyJSON
import Quick
import Nimble

class GistServiceTests: QuickSpec {
  
  override func spec() {
    
    fdescribe("uploadGist") {
      
      context("Upload was successful") {
        
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
      }
      
      context("Upload was unsuccessful") {
      }
    }
  }
}