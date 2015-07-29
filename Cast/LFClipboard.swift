//
//  LFClipboard.swift
//  Cast
//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Foundation

//TODO: Implement the Clipboard controller class
let apiCall = LFAPICalls()
func processClipboard() {
    apiCall.uploadString("Casted")
}
