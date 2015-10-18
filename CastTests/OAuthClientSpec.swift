//
//  OAuthService.swift
//  Cast
//
//  Created by Leonardo on 19/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift
import SwiftyJSON
import Quick
import Nimble

@testable import Cast

class OAuthClientSpec: QuickSpec {
    override func spec() {

        describe("OAuthClient") {
            context("calling the API") {
//                let oauth: OAuthClient?
//
//                beforeEach {
//                    oauth = OAuthClient(
//                        clientID: "ef09cfdbba0dfd807592",
//                        clientSecret: "ce7541f7a3d34c2ff5b20207a3036ce2ad811cc7",
//                        service: OAuthClientConfig.GitHub
//                    )
//                }
//                
//                xit("Request authentication") {
//                    oauth!.authorize()
//                    
////                    expect(oauth.check).to(beTrue())
//                }

                xit("can revoke authentication") {
                    let revoked = OAuthClient.revoke()
                    
					expect(revoked).to(beNil())
                }
                
                it("can give you the authorization token") {
					let authToken: String? = OAuthClient.getToken()

					expect(authToken).toNot(beNil())
                }
            }
            
        }
    }
}
