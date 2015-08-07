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
//---------------------------------------------------------------------------
/// Pasteboard: an object that holds one or more objects of any type
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
  //FIXME: Find a better implementation
  func extractData() throws -> PasteboardData {
    print(__FUNCTION__)
    if let pasteboardItems = pasteboard.readObjectsForClasses(classes, options: nil)?.flatMap({ PasteboardData(anyData: $0) })
      where !pasteboardItems.isEmpty {
        print(pasteboardItems[0])
        return pasteboardItems[0]
    }
    throw CastErrors.EmptyPasteboardError
  }
  //---------------------------------------------------------------------------
  //FIXME: Figure out a way to understand which class is AnyObject and cast accordingly
  func copyToClipboard(objects: [AnyObject]) {
    print(__FUNCTION__)
    pasteboard.clearContents()
    let extractedStrings = objects.flatMap({ String($0) })
    if extractedStrings.isEmpty { fatalError("no data") }
    if pasteboard.writeObjects(extractedStrings) {
      print("success")
      for text in extractedStrings {
        print(text)
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
