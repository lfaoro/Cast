//
//  LFClipboard.swift
//  Cast
//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Foundation

//TODO: Implement the Clipboard controller class
final class LFClipboard: NSObject {
    let apiCall = LFAPICalls()
    //---------------------------------------------------------------------------
    func process() {
        apiCall.uploadString("Casted")
    }
}
