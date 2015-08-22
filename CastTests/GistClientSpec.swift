
import Cocoa
import RxCocoa
import RxSwift
import SwiftyJSON
import Quick
import Nimble

class GistClientSpec: QuickSpec {
    override func spec() {
        
        describe("API") {
            
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
        }
    }
    
}