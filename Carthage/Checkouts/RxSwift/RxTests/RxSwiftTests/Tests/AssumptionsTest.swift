//
//  AssumptionsTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import CoreGraphics

var deallocated = false
var realTest: Anything? = nil

func clearRealTest() {
    realTest = nil
}

func returnSomething() -> Observable<AnyObject?> {
    return just("a")
}

func returnSomething() -> Observable<CGRect?> {
    return just(CGRectMake(0, 0, 100, 100))
}

class AssumptionsTest : RxTest {
    func testAssumptionInCodeIsThatArraysAreStructs() {
        let a = ["a"]
        var b = a
        b += ["b"]
        
        XCTAssert(a == ["a"])
        XCTAssert(b == ["a", "b"])
    }
   
    // http://lists.apple.com/archives/objc-language/2011/Nov/msg00005.html
    // but you never know :)
    func testFunctionCallRetainsArguments() {
        
        // first check is dealloc method working
        
        var a: Anything? = Anything()
        print(a)
        XCTAssertFalse(deallocated)
        a = nil
        XCTAssertTrue(deallocated)
        
        // then check unsafe
        
        deallocated = false
        
        realTest = Anything()
        
        XCTAssertFalse(deallocated)
        
        realTest?.justCallIt {
            XCTAssertFalse(deallocated)
            realTest = nil
            XCTAssertFalse(deallocated)
        }
        XCTAssertTrue(deallocated)
    }
    
    func testFunctionReturnValueOverload() {
        returnSomething()
            .subscribeNext { (n: AnyObject?) in
                XCTAssertEqual("\(n ?? NSNull())", "a")
            }

        returnSomething()
            .subscribeNext { (n: CGRect?) in
                XCTAssertEqual(n!, CGRectMake(0, 0, 100, 100))
             }
    }
    
    func testArrayMutation() {
        var a = [1, 2, 3, 4]
        
        let b = a
        
        var count = 0
        for _ in b {
            a.removeAll()
            count++
        }
        
        XCTAssertTrue(count == 4)
    }
    
    func testResourceLeaksDetectionIsTurnedOn() {
#if TRACE_RESOURCES
        let startResourceCount = resourceCount
    
        var observable: Observable<Int>! = Observable()
        
        XCTAssertEqual(resourceCount, startResourceCount + 1)
        
        observable = nil

        XCTAssertEqual(resourceCount, startResourceCount)
#elseif RELEASE

#else
        XCTAssert(false, "Can't run unit tests in without tracing")
#endif
    }
}



class Anything {
    var elements = [Int]()
    
    func justCallIt(action: () -> Void) {
        clearRealTest()
        action()
    }
    
    deinit {
        deallocated = true
    }
}
