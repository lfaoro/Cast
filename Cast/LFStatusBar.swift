//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//


// Cast: verb. throw (something) forcefully in a specified direction.

import Cocoa


//MARK:
class LFStatusBar: NSObject {
    
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    //HELP: Records that will populate the Menu
    var recentUploads: [String:String] = ["TestTitle1":"https://apple.com/","TestTitle2":"https://github.com"]
    
    var startAtLoginSwitch: Bool = true
    
    
    //MARK:-
    func displayStatusBarItem() {
        
        statusBarItem.button?.title = "Cast"
        statusBarItem.button?.image = NSImage(named: "LFStatusBarIcon")
        statusBarItem.button?.alternateImage = NSImage(named: "LFStatusBarAlternateIcon")
        
        statusBarItem.button?.registerForDraggedTypes(pasteboardTypes)
        
        addMenu()
        
    }
    
    private func addMenu() {
        let menu = NSMenu(title: "Cast Menu")
        
        menu.addItemWithTitle("Share Clipboard Content", action: "shareClipboardContentAction:", keyEquivalent: "S")
        
        menu.addItem(NSMenuItem.separatorItem())
        
        let recentUploadsItem = NSMenuItem(title: "Recent Uploads", action: "terminate:", keyEquivalent: "")
        
        let recentUploadsSubmenu = NSMenu(title: "Cast - Recent Uploads Menu")
        
        if recentUploads.count > 1 {
            for (title,link) in recentUploads {
                
                let menuItem = NSMenuItem(title: title, action: "recentUploadsAction:", keyEquivalent: "")
                
                // Allows me to use a value from this context in the func called by the selector
                menuItem.representedObject = link
                
                menuItem.target = self
                recentUploadsSubmenu.addItem(menuItem)
            }
        }
        
        recentUploadsSubmenu.addItem(NSMenuItem.separatorItem())
        recentUploadsSubmenu.addItemWithTitle("Clear Recents", action: "clearItemsAction:", keyEquivalent: "")?.target = self
        
        recentUploadsItem.submenu = recentUploadsSubmenu
        menu.addItem(recentUploadsItem)
        
        menu.addItemWithTitle("Start at Login", action: "startAtLoginAction:", keyEquivalent: "")!.target = self
        
        menu.addItemWithTitle("Quit", action: "terminate:", keyEquivalent: "Q")
        
        statusBarItem.menu = menu
    }
    
    //MARK:- NSMenuItem selectors
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
    
    func clearItemsAction(sender: NSMenuItem) {
        
        if recentUploads.count > 0 {
            recentUploads.removeAll()
            Swift.print(recentUploads)
            sender.menu?.removeAllItems()
            //            sender.hidden = true
            //            addMenu()
        }
        
    }
    
    func startAtLoginAction(sender: NSMenuItem) {
        
        
        if sender.state == 0 {
            sender.state = 1
        } else {
            sender.state = 0
        }
        
    }
    
    
    
}

//MARK:- (Pr) NSDraggingDestination implementation
extension NSStatusBarButton {
    
    public override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        Swift.print("Called: draggingEntered")
        return NSDragOperation.Copy
        
    }
    
    public override func draggingExited(sender: NSDraggingInfo?) {
        Swift.print("Called: draggingExited")
    }
    
}