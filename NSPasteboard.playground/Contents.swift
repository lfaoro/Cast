import Cocoa
import XCPlaygroundadas

let pasteBoardItem = NSPasteboard
    .generalPasteboard()
    .pasteboardItems?
    .map{$0.dataForType(NSPasteboardTypePNG)}
    .flatMap{$0}

if let item = pasteBoardItem {
    print(item)

//NSImageView().image = NSImage(data: item[0]) 
    
}

let aPasteboard = NSPasteboard
    .generalPasteboard()

let classes: [AnyClass] = [NSString.self]


