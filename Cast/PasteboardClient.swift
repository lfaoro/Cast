//
//  Created by Leonardo on 29/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//


import Cocoa
import RxSwift


enum PBError: ErrorType {
	case UnreadableData
}

enum PBItem {
	case Text(String) //to Gist
	case Image(NSImage) //to Imgur
	case File(NSURL) //to Dropbox/iCloud
}


func putInPasteboard(items items: [String]) -> Bool {
	let pb = NSPasteboard.generalPasteboard()

	pb.clearContents()

	return pb.writeObjects(items)
}

func getPasteboardItems() -> Observable<PBItem> {
	let pasteBoard = NSPasteboard.generalPasteboard()
	let classes: [AnyClass] = [NSURL.self, NSString.self, NSAttributedString.self, NSImage.self]
	let options: [String:AnyObject] = [:]
	let copiedItems = pasteBoard.readObjectsForClasses(classes, options: options)

	return create {
		stream in
		if let items = copiedItems {

			for item in items {
				switchOnItem(stream, item: item)
			}
			sendCompleted(stream)
			// Question: SHOULD THERE BE A RETURN HERE?
		}

		sendError(stream, PBError.UnreadableData)

		return NopDisposable.instance
	}
}

func switchOnItem(stream: ObserverOf<PBItem>, item: AnyObject) {
	switch item {
	case let image as NSImage:
		sendNext(stream, .Image(image))

	case let text as NSString:
		sendNext(stream, .Text(String(text)))

	case let attrText as NSAttributedString:
		sendNext(stream, .Text(attrText.string))

	case let file as NSURL:
		sendNext(stream, .File(file))

	default: //blow up
		preconditionFailure()
	}
	
}

