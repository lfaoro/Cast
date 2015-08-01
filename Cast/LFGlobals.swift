//
//  Global.swift
//  Cast
//
//  Created by Leonardo on 19/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa

public var recentUploads: [String:String] = ["TestTitle1":"https://apple.com/","TestTitle2":"https://github.com"]
public let pasteboardTypes = [NSFilenamesPboardType]

let app = NSApp.delegate as! AppDelegate