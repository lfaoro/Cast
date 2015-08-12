//: Playground - noun: a place where people can play

import Cocoa
import SwiftyJSON
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely(true)

var str = "Hello, playground"

let callback = "cast://oauth?code=d1a3f88b22ce1ae2e23e&state=7601EE62-FAD0-4F07-8290-2A5DD99F131A"
let items = NSURLComponents(string: callback)!.queryItems!
items[0].value
items.map{$0}
