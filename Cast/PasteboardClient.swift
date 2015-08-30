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

class PasteboardClient {

	class func putInPasteboard(items items: [String]) -> Bool {
		let pb = NSPasteboard.generalPasteboard()

		pb.clearContents()

		return pb.writeObjects(items)
	}

	class func getPasteboardItems() -> Observable<PBItem> {
		let pb = NSPasteboard.generalPasteboard()

		let classes: [AnyClass] = [NSURL.self,NSString.self,NSAttributedString.self,NSImage.self]
		let options: [String: AnyObject] = [ :
			//            NSPasteboardURLReadingFileURLsOnlyKey: NSNumber(bool: true),
			//            NSPasteboardURLReadingContentsConformToTypesKey: NSImage.imageTypes(),
		]

		let copiedItems = pb.readObjectsForClasses(classes, options: options)

		return create { stream in
			if let items = copiedItems {

				for item in items {
					if let image = item as? NSImage {
						sendNext(stream, .Image(image))
					}

					if let text = item as? NSString {
						sendNext(stream, .Text(String(text)))
					}

					if let attrText = item as? NSAttributedString {
						sendNext(stream, .Text(attrText.string))
					}

					if let file = item as? NSURL {
						sendNext(stream, .File(file))
					}
				}

				sendCompleted(stream)
			}

			sendError(stream, PBError.UnreadableData)

			return NopDisposable.instance
		}
	}
}
