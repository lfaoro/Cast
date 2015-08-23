
import Cocoa
import RxCocoa
import RxSwift
import RxBlocking
import SwiftyJSON
import Quick
import Nimble

@testable import Cast

class GistClientSpec: QuickSpec {
    override func spec() {
        
        describe("GistClient") {
            
            context("API") {
                var gistClient: GistClient!
                
                beforeEach {
                    gistClient = GistClient()
                }
                
                it(""){
                    
                    let x = just(1)
                    
                    expect(x.last.get()) == 1
                }
                
                it("can create gists") {
                    
                   let signal = gistClient.setGist(content: "testing Content")
                    
                    expect(signal.last.get()?.host) == "gist.github.com"
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