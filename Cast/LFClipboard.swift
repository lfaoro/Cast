//
//  LFClipboard.swift
//  Cast
//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
// Clipboard: an object that holds one or more objects of any type

final class LFClipboard: NSObject {
    let pasteboard = NSPasteboard.generalPasteboard()
    let apiCall = LFAPICalls()
    let classes: [AnyClass] = [
        NSString.self,
        /*
        NSImage.self,
        NSURL.self,
        NSAttributedString.self,
        NSSound.self,
        NSPasteboardItem.self
        */
    ]
    let options = [
        NSPasteboardURLReadingFileURLsOnlyKey: NSNumber(bool: true),
        NSPasteboardURLReadingContentsConformToTypesKey: NSImage.imageTypes()
    ]
    //---------------------------------------------------------------------------
    //FIXME: Find a better implementation
    func extractData() -> String {
        if let pasteboardItems = pasteboard
            .readObjectsForClasses(classes, options: options)?
            .flatMap({ ($0 as? String) }) {
            if !pasteboardItems.isEmpty {
                print(pasteboardItems[0])
                pasteboard.clearContents()
                return pasteboardItems[0]
            }
        }
        return "Incompatible data or no data"
    }
    //---------------------------------------------------------------------------
    func process() {
        apiCall.uploadString(extractData())
    }
}
