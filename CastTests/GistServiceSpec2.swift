import Cocoa
import SwiftyJSON
import Quick
import Nimble

class GistServiceTests: QuickSpec {
    
    override func spec() {
        
        describe("GistService class") {
            
            context("Testing Public API") {
                
                var gistService: GistService!
                var gistURL: NSURL?
                var gistID: String?
                
                beforeEach {
                    gistService = GistService()
                }
                
                
                it(".setGist()") {
                    gistService.setGist(content: "test data")
                        .on(next: {
                            gistURL = $0.0
                            gistID = $0.1
                        })
                        .start()
                    
                    expect(gistURL).toEventuallyNot(beNil())
                    expect(gistID).toEventuallyNot(beNil())
                }
                
                
                it(".reset()") {
                    
                    expect(gistService.resetGist()).to(beTrue())
                    
                    expect(gistService.gistID).to(beNil())
                }
            }
            
            context("Upload was unsuccessful") {
            }
        }
    }
}