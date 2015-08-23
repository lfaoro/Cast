//
//  GistService.swift
//  Cast
//
//  Created by Leonardo on 08/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely(true)

var gistID: String? {
get {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    return userDefaults.stringForKey("gistID")
}
set (value) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(value, forKey: "gistID")
}
}




gistID = "ciao"

print(gistID)



