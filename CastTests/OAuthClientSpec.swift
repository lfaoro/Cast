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

class OAuthClientSpec: QuickSpec {
    override func spec() {
        describe("OAuthClient") {
            
            context("calling the API") {
                let oauth: OAuthClient!
                
                
                beforeEach {
                    oauth = OAuthClient(
                        clientID: "ef09cfdbba0dfd807592",
                        clientSecret: "ce7541f7a3d34c2ff5b20207a3036ce2ad811cc7",
                        service: OAuthService.GitHub
                    )
                }
                
                xit("can request authentication") {
                    oauth.authorize()
                        .subscribe { event in
                            switch event {
                            case .Next(let value):
                                print("\(value)")
                            case .Completed:
                                print("Authentication Successful")
                            case .Error(let error):
                                print("\(error)")
                            }
                    }
                    
                    expect(oauth.check).to(beTrue())
                }
                
                xit("can revoke authentication") {
                    oauth.revoke()
                    
                    expect(oauth.checkAuthentication).to(beFalse())
                }
                
                xit("can check if authenticated") {
                    let isAuthenticated: Bool = oauth.check()
                }
                
                xit("can give you the authorization token") {
                    let authToken: String = oauth.getToken()
                }
            }
            
        }
    }
}
