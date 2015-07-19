//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//


// Cast: verb. throw (something) forcefully in a specified direction.

import Cocoa

<<<<<<< HEAD

//MARK:
=======
>>>>>>> origin/master
class LFStatusBar: NSObject {
    
    var statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    //HELP: Records that will populate the Menu
    var recentUploads: [String:String] = ["TestTitle1":"https://apple.com/","TestTitle2":"https://github.com"]
    
    var startAtLoginSwitch: Bool = true
    
    
    func displayStatusBarItem() {
<<<<<<< HEAD
        
        statusBarItem.button?.title = "Cast"
        statusBarItem.button?.image = NSImage(named: "LFStatusBarIcon")
        statusBarItem.button?.alternateImage = NSImage(named: "LFStatusBarAlternateIcon")
        
        statusBarItem.button?.registerForDraggedTypes(pasteboardTypes)
        
        addMenu()
=======
        //TODO: Registering for Drag'n'Drop
        precondition(statusBarItem.button!.registeredDraggedTypes.isEmpty)

        if let b = statusBarItem.button {
            b.title = "Cast"
            b.image = NSImage(named: "LFStatusBarIcon")
            b.alternateImage = NSImage(named: "LFStatusBarAlternateIcon")

            b.registerForDraggedTypes([NSFilenamesPboardType])
            precondition(!b.registeredDraggedTypes.isEmpty)
        }
>>>>>>> origin/master
        
        statusBarItem.menu = addMenu()
    }
    
<<<<<<< HEAD
    private func addMenu() {
=======
    func addMenu() -> NSMenu {
>>>>>>> origin/master
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
        
        return menu
    }
    
<<<<<<< HEAD
    //MARK:- NSMenuItem selectors
    func shareClipboardContentAction() {
        
=======
    //MARK:- Selectors
    
    func shareClipboardContentAction(sender: AnyObject) {
        print(__FUNCTION__)
>>>>>>> origin/master
    }
    
    func recentUploadsAction(sender: AnyObject) {
        let url = NSURL(string: sender.representedObject as! String)
        if let url = url {
            NSWorkspace.sharedWorkspace().openURL(url)
        } else {
            fatalError("No link in recent uploads")
        }
    }
    
<<<<<<< HEAD
    func clearItemsAction(sender: NSMenuItem) {
        
=======
    func clearItemsAction(sender: AnyObject) {
>>>>>>> origin/master
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
<<<<<<< HEAD
            sender.state = 0
=======
            if let s = sender as? NSMenuItem {
                s.enabled = false
            }
>>>>>>> origin/master
        }
        
    }
    
    
    
}

<<<<<<< HEAD
//MARK:- (Pr) NSDraggingDestination implementation
extension NSStatusBarButton {
    
    public override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        Swift.print("Called: draggingEntered")
        return NSDragOperation.Copy
=======
// Conforming to Protocol NSDraggingDestination
extension LFStatusBar: NSDraggingDestination {
   
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        print(__FUNCTION__)
        
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        
        if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            if sourceDragMask.rawValue & NSDragOperation.Generic.rawValue != 0 {
                return NSDragOperation.Generic
            }
        }
>>>>>>> origin/master
        
    }
    
<<<<<<< HEAD
    public override func draggingExited(sender: NSDraggingInfo?) {
        Swift.print("Called: draggingExited")
=======
    func performDragOperation(sender: NSDraggingInfo) -> Bool {
        print(__FUNCTION__)
        
        
        return true
>>>>>>> origin/master
    }
    
}
