//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

// Cast: verb. throw (something) forcefully in a specified direction.

import Cocoa

final class LFStatusBar: NSObject {
    let api = LFAPICalls()
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    //HELP: Records that will populate the Menu
    //---------------------------------------------------------------------------
    func displayStatusBarItem() {
        statusBarItem.button?.title = "Cast"
        let image = NSImage(named: "LFStatusBarIcon")
        image?.template = true
        statusBarItem.button?.image = image
        statusBarItem.button?.alternateImage = NSImage(named: "LFStatusBarAlternateIcon")
        statusBarItem.button?.registerForDraggedTypes(pasteboardTypes) //TODO: Implement dragging
        statusBarItem.menu = createMenu()
    }
    //---------------------------------------------------------------------------
    func createMenu() -> NSMenu {
        let menu = NSMenu(title: "Cast Menu")
        menu.addItemWithTitle("Share", action: "shareClipboardContentsAction:", keyEquivalent: "S")?.target = self
        menu.addItem(NSMenuItem.separatorItem())
        //---------------------------------------------------------------------------
        let recentUploadsItem = NSMenuItem(title: "Recent Uploads", action: "terminate:", keyEquivalent: "")
        let recentUploadsSubmenu = NSMenu(title: "Cast - Recent Uploads Menu")
        if recentUploads.count > 0 {
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
        //---------------------------------------------------------------------------
        menu.addItem(recentUploadsItem)
        menu.addItemWithTitle("Start at Login", action: "startAtLoginAction:", keyEquivalent: "")!.target = self
        menu.addItemWithTitle("Quit", action: "terminate:", keyEquivalent: "Q")
        //---------------------------------------------------------------------------
        return menu
    }
    //---------------------------------------------------------------------------
    //MARK:- NSMenuItem selectors
    func shareClipboardContentsAction(sender: NSMenuItem) {
        self.api.share()
    }
    //---------------------------------------------------------------------------
    func recentUploadsAction(sender: NSMenuItem) {
        let url = NSURL(string: sender.representedObject as! String)
        if let url = url {
            NSWorkspace.sharedWorkspace().openURL(url)
        } else {
            fatalError("No link in recent uploads")
        }
    }
    //---------------------------------------------------------------------------
    func clearItemsAction(sender: NSMenuItem) {
        if recentUploads.count > 0 {
            recentUploads.removeAll()
            Swift.print(recentUploads)
            //            sender.menu?.removeAllItems()
            self.statusBarItem.menu!.update()
        }
    }
    //---------------------------------------------------------------------------
    func startAtLoginAction(sender: NSMenuItem) {
        if sender.state == 0 {
            sender.state = 1
        } else {
            sender.state = 0
        }
    }
    //---------------------------------------------------------------------------
}
