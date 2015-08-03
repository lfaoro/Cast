//
//  Options.swift
//  Cast
//
//  Created by Leonardo on 02/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa
import CleanroomLogger

final class Options: NSObject {
  //---------------------------------------------------------------------------
  var optionsWC: NSWindowController?
  //---------------------------------------------------------------------------
  func displayOptionsWindow() -> () {
    Log.info?.trace()
    optionsWC = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle())
      .instantiateControllerWithIdentifier("optionsWC") as? NSWindowController
    optionsWC?.window?.makeKeyAndOrderFront(NSApp)
  }
}
