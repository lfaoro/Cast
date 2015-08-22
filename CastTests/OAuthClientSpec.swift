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
        describe("API") {
            let oauth
            
            it("can request authentication") {
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
            
            it("can revoke authentication") {
                oauth.revoke()
                
                expect(oauth.checkAuthentication).to(beFalse())
            }
            
            it("can check if authenticated") {
                let isAuthenticated: Bool = oauth.check()
            }
            
            it("can give you the authorization token") {
                let authToken: String = oauth.getToken()
            }
            
        }
    }
}
