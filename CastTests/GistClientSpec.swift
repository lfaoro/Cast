
import Cocoa
import RxCocoa
import RxSwift
import SwiftyJSON
import Quick
import Nimble

class GistClientSpec: QuickSpec {
    override func spec() {
        
        describe("GistClient") {
            
            context("API") {
                var gistClient: GistClient!
                var link: NSURL?
                
                
                beforeEach {
                    gistClient = GistClient()
                }
                
                it("can create gists") {
                    
                    gistClient.setGist(content: "testing Content")
                        .retry(3)
                        .subscribeNext({ event in
                            link = event
                        })
                    
                    expect(link).toEventuallyNot(beNil())
                    expect(link?.host).to(equal("gist.github.com"))
                }
                
                it("can be initialized with a different URL") {
                    
                    gistClient = GistClient(baseURLString: "https://api.github.com/gists")
                    
                    expect(gistClient.gistAPIURL.relativeString).to(equal("https://api.github.com/gists"))
                }
            }
            
            context("Failures") {
                var gistClient: GistClient?
                var gistError: ErrorType?
                
                beforeEach {
                    gistClient = GistClient(baseURLString: "@\\:pop")
                }
                
                it("can fail on initialization") {
                    
                    
                    expect(gistClient).to(beNil())
                }
                
                it("can fail during the connection") {
                    
                    gistClient?.setGist(content: "test content")
                        .subscribeError({ (error: ErrorType) in
                        gistError = error
                    })
                    
                    expect(gistError).toEventuallyNot(beNil())
                }
            }
            
        }
    }
    
}