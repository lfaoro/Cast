//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//


// Cast: verb. throw (something) forcefully in a specified direction.

import Cocoa

class LFStatusBar: NSObject {
    
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    //HELP: Records that will populate the Menu
    var recentUploads: [String:String] = ["TestTitle1":"https://apple.com/","TestTitle2":"https://github.com"]
    
    func displayStatusBarItem() {
        
        statusBarItem.button?.title = "Cast"
        statusBarItem.button?.image = NSImage(named: "LFStatusBarIcon")
        statusBarItem.button?.alternateImage = NSImage(named: "LFStatusBarAlternateIcon")
        statusBarItem.button?.highlight(false)
        
        addMenu()
        
    }
    
    //MARK:-
    func addMenu() {
        let menu = NSMenu(title: "Cast Menu")
        
        menu.addItemWithTitle("Share Clipboard Content", action: "shareClipboardContentAction:", keyEquivalent: "S")
        menu.addItem(NSMenuItem.separatorItem())
        
        let recentUploadsItem = NSMenuItem(title: "Recent Uploads", action: "terminate:", keyEquivalent: "")
        let recentUploadsSubmenu = NSMenu(title: "Cast - Recent Uploads Menu")
        
        if recentUploads.count > 1 {
            for (title,link) in recentUploads {
                
                //HELP: How do I add the `link` argument to the selector `recentUploadsAction:`
                //Is there any other way to pass in the value of link which is differnt for every menuItem?
                let menuItem = NSMenuItem(title: title, action: "recentUploadsAction:", keyEquivalent: "")
                menuItem.representedObject = link
                menuItem.target = self
                recentUploadsSubmenu.addItem(menuItem)
            }
        }
        
        recentUploadsItem.submenu = recentUploadsSubmenu
        menu.addItem(recentUploadsItem)
        
        menu.addItemWithTitle("Quit", action: "terminate:", keyEquivalent: "Q")
        
        statusBarItem.menu = menu
    }
    
    //MARK:- Selectors
    func shareClipboardContentAction() {
        
    }
    
    func recentUploadsAction(sender: AnyObject) {
        
        let url = NSURL(string: sender.representedObject as! String)
        if let url = url {
            NSWorkspace.sharedWorkspace().openURL(url)
        } else {
            fatalError("No link in recent uploads")
        }
    }
    
    
    
}



