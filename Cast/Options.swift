//
//  Options.swift
//  Cast
//
//  Created by Leonardo on 02/08/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa
import SwiftyJSON

final class Options: NSObject {
  //---------------------------------------------------------------------------
  var optionsWC: NSWindowController?
  //---------------------------------------------------------------------------
  func displayOptionsWindow() -> () {
    optionsWC = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle())
      .instantiateControllerWithIdentifier("optionsWC") as? NSWindowController
    optionsWC?.window?.makeKeyAndOrderFront(NSApp)

    let servicesPlist = NSBundle.mainBundle().pathForResource("Services", ofType: "plist")!
    let services = JSON(NSDictionary(contentsOfFile: servicesPlist)!)
    print(services["Gist"]["URL"].string!)
  }
}
