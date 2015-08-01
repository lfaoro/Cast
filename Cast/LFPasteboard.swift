//
//  LFClipboard.swift
//  Cast
//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
// Clipboard: an object that holds one or more objects of any type

//TODO: Rename Clipboard to Pasteboard
final class LFPasteboard: NSObject {
    let pasteboard = NSPasteboard.generalPasteboard()
    let notification = LFNotifications()
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

	deinit {
		print("DEINIT")
	}

    //FIXME: Find a better implementation
    func extractData() -> String {
        print(__FUNCTION__)
        if let pasteboardItems = pasteboard
            .readObjectsForClasses(classes, options: options)?
            .flatMap({ ($0 as? String) }) {
                if !pasteboardItems.isEmpty {
                    print(pasteboardItems[0])
                    return pasteboardItems[0]
                }
        }
        return "Incompatible data or no data"
    }
    //---------------------------------------------------------------------------
    //FIXME: Figure out a way to understand which class is AnyObject and cast accordingly
    func copyToClipboard(objects: [AnyObject]) -> Void {
        print(__FUNCTION__)
        let pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.clearContents()
        let extractedStrings = objects.flatMap({ String($0) })
        if extractedStrings.isEmpty { fatalError("no data") }
        if pasteboard.writeObjects(extractedStrings) {
            print("success")
            for text in extractedStrings {
                print(text)
                notification.pushNotification(openURL: text)
            }
        } else {
            notification.pushNotification(error: "Can't write to Pasteboard")
        }
    }
    //---------------------------------------------------------------------------
}
