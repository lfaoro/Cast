//: Playground - noun: a place where people can play

import Cocoa
import SwiftyJSON
import RxSwift
import RxCocoa
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely(true)

enum ConnectionError: ErrorType {
    case Bad(String)
    case Worse(String)
    case Terrible(String)
}
var o: Observable<(String,String)>.E = (URL: "test", ID: "test2")
print(o.dynamicType)

