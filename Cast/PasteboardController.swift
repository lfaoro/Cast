//
//  LFClipboard.swift
//  Cast
//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa

enum CastErrors: ErrorType {
  case EmptyPasteboardError
}
//---------------------------------------------------------------------------
public enum PasteboardData {
  case Text(String)
  case Image(NSImage)
  case Reference(NSURL)
  case Number(NSNumber)
  case Error(String)

  public init?(anyData: AnyObject) {
    switch anyData {
    case let stringData as String: self = PasteboardData.Text(stringData)
    case let imageData as NSImage: self = PasteboardData.Image(imageData)
    default: return nil
    }
  }
}

/*

get the pasteboard
parse it for NSString.self data
return the result

make a function

*/


//---------------------------------------------------------------------------
/// Pasteboard: an object that holds one or more objects of any type
///- todo: refactor PasteboardController
///- todo: find better name for pasteboardcontroller
final class PasteboardController: NSObject {
  let pasteboard = NSPasteboard.generalPasteboard()
  let classes: [AnyClass] = [
    NSString.self,
    NSImage.self,
    /*
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
  func extractData() throws -> PasteboardData {
    if let pasteboardItems = pasteboard.readObjectsForClasses(classes, options: nil)?
			.flatMap({ PasteboardData(anyData: $0) }) where !pasteboardItems.isEmpty {
        return pasteboardItems[0]
    }
    throw CastErrors.EmptyPasteboardError
  }
  //---------------------------------------------------------------------------
  func copyToClipboard(objects: [AnyObject]) {
    pasteboard.clearContents()
    let extractedStrings = objects.flatMap({ String($0) })
    if extractedStrings.isEmpty { fatalError("no data") }
    if pasteboard.writeObjects(extractedStrings) {
      for text in extractedStrings {
        dispatch_async(dispatch_get_main_queue()) {
          app.userNotification.pushNotification(openURL: text)
        }
      }
    } else {
      app.userNotification.pushNotification(error: "Can't write to Pasteboard")
    }
  }
  //---------------------------------------------------------------------------
}
