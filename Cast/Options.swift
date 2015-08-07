//
//  Options.swift
//  Cast
//
//  Created by Leonardo on 02/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa

final class Options: NSObject {
  //---------------------------------------------------------------------------
  var optionsWC: NSWindowController?
  //---------------------------------------------------------------------------
  func displayOptionsWindow() -> () {
    optionsWC = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle())
      .instantiateControllerWithIdentifier("optionsWC") as? NSWindowController
    optionsWC?.window?.makeKeyAndOrderFront(NSApp)
    
    let sharingServicesPath = NSBundle.mainBundle().pathForResource("SharingServices", ofType: "plist")!
    let sharingServices = NSDictionary(contentsOfFile: "sharingServicesPath")
    print(sharingServices)
  }
}
