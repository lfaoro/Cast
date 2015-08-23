
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
                
                it("can update/create gists") {
                    
                   let stream = gistClient.setGist(content: "testing Content")
                    
                    expect(stream.last.get()?.host) == "gist.github.com"
                }
                
                it("can create gists") {
                    
                    let stream = gistClient.setGist(content: "testing Content", updateGist: false)
                    
                    expect(stream.last.get()?.host) == "gist.github.com"
                }
            }
            
            context("Failures") {
                var gistClient: GistClient?
                var gistError: ErrorType?
                
                beforeEach {
                    gistError = nil
                    gistClient = nil
                }
                
                it("can fail on initialization") {
                    
                    gistClient = GistClient(baseURLString: "@\\:pop")
                    
                    expect(gistClient).to(beNil())
                }
                
                it("can fail during the connection") {
                    
                    gistClient = GistClient(baseURLString: "http://dummyConnection.xyz")
                    
                    gistClient?.setGist(content: "test content")
                        .subscribeError({ (error: ErrorType) in
                        gistError = error
                    })
                    
                    expect(gistError).toEventuallyNot(beNil())
                }
                
                it("can error on a Bad response") {
                    
                    gistClient = GistClient(baseURLString: "https://api.github.com/gists/err")
                    
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