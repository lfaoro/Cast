//: Playground - noun: a place where people can play

import Cocoa
import SwiftyJSON
import RxSwift
import RxCocoa
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely(true)

let example:(String,()->Void)->Void = { _,b in b()}
let xexample:(String,()->Void)->Void = { _,b in /* do nothing */}

xexample("enum") {
    enum Spotlight {
        case Red, Yellow, Green
    }
    
    let cornerSpotlight: Spotlight = .Red
    
    switch cornerSpotlight {
    case .Red: print("Stop!")
    case .Yellow: print("Wait...")
    case .Green: print("GO!")
    }
}

func test() -> Observable<Int> {
    return create { obs in
        for i in 0...10 {
            sendNext(obs, i)
        }
        sendCompleted(obs)
        
        return NopDisposable.instance
    }
}

xexample("combine Ints") {
    combineLatest(test(), test()) { $0 + $1 }
        .debug()
        .map {$0 + 100}
        .subscribe(print)
}

let bag = DisposeBag()
xexample("Timer") {
    let source = timer(1, 2, scheduler: MainScheduler.sharedInstance)
        .debug()
        .take(2)
        .subscribe({print("next: \($0)")}, error: {print("error: \($0)")}, completed: {print("complete: \($0)")})
    
    bag.addDisposable(source)
}

xexample("Deferred") {
    // don't like it
}

xexample("From") {
    let a = Array(1...100)
    
    let source = from(a)
        .debug()
//        .throttle(5, MainScheduler.sharedInstance)
        .take(5)
//        .debounce(3, scheduler: MainScheduler.sharedInstance)
        .subscribe({print("next: \($0)")}, error: {print("error: \($0)")}, completed: {
            print("complete: \($0)")
            
        })
}

xexample("From/Distinct") {
    let a = Array(1...50)
    let b = a + Array(1...50)
    
    let source = from(b)
//        .debug()
        .subscribe({print("next: \($0)")}, error: {print("error: \($0)")}, completed: {
            print("complete: \($0)")
            
        })
}

example("of merge") { _ in
    let A = from(["a1","a2","a3","a4"])
    let B = from(["b1","b2","b3","b4","b5"])
    sequence(A,B).merge.subscribe(print)
}
















