import Cocoa
import SwiftyJSON
import Quick
import Nimble

class GistServiceTests: QuickSpec {
    
    override func spec() {
        
        describe("GistService") {
            
            context("Testing Public API: success") {
                
                var gistService: GistService!
                var gistURL: String?
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
            
            context("Testing Public API: failures") {
                var gistService: GistService!
                var gistURL: String?
                var gistID: String?
                
                beforeEach {
                    gistService = GistService(apiURL: "http://api.fakeHost.com/gists")
                }
                
                it(".setGist()") {
                    gistService.setGist(content: "test Data")
                        .on(next: {
                            gistURL = $0.0
                            gistID = $0.1
                        })
                        .start()
                    
                    expect(gistURL).toEventually(beNil())
                    expect(gistID).toEventually(beNil())
                }
                
            }
        }
        
    }
}