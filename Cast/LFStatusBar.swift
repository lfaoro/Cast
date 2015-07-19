//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//


// Cast: verb. throw (something) forcefully in a specified direction.

import Cocoa

class LFStatusBar: NSObject {
    
    var statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    //HELP: Records that will populate the Menu
    var recentUploads: [String:String] = ["TestTitle1":"https://apple.com/","TestTitle2":"https://github.com"]
    
    
    func displayStatusBarItem() {
        //TODO: Registering for Drag'n'Drop
        precondition(statusBarItem.button!.registeredDraggedTypes.isEmpty)

        if let b = statusBarItem.button {
            b.title = "Cast"
            b.image = NSImage(named: "LFStatusBarIcon")
            b.alternateImage = NSImage(named: "LFStatusBarAlternateIcon")

            b.registerForDraggedTypes([NSFilenamesPboardType])
            precondition(!b.registeredDraggedTypes.isEmpty)
        }
        
        statusBarItem.menu = addMenu()
    }
    
    func addMenu() -> NSMenu {
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
        
        menu.addItemWithTitle("Quit", action: "terminate:", keyEquivalent: "Q")
        
        return menu
    }
    
    //MARK:- Selectors
    
    func shareClipboardContentAction(sender: AnyObject) {
        print(__FUNCTION__)
    }
    
    func recentUploadsAction(sender: AnyObject) {
        let url = NSURL(string: sender.representedObject as! String)
        if let url = url {
            NSWorkspace.sharedWorkspace().openURL(url)
        } else {
            fatalError("No link in recent uploads")
        }
    }
    
    func clearItemsAction(sender: AnyObject) {
        if recentUploads.count > 0 {
            recentUploads.removeAll()
            addMenu()
        } else {
            if let s = sender as? NSMenuItem {
                s.enabled = false
            }
        }
        
    }
    
    
    
}

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
        
        return NSDragOperation.None
    }
    
    func performDragOperation(sender: NSDraggingInfo) -> Bool {
        print(__FUNCTION__)
        
        
        return true
    }
    
    //    - (BOOL)statusItemView:(BCStatusItemView *)view performDragOperation:(id <NSDraggingInfo>)info
    //    {
    //    NSArray *possibleItemClasses = [NSArray arrayWithObjects:NSString.class, NSURL.class, nil];
    //    NSDictionary *pasteboardOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
    //    forKey:NSPasteboardURLReadingFileURLsOnlyKey];
    //    NSArray *pasteboardItems = [[info draggingPasteboard] readObjectsForClasses:possibleItemClasses
    //    options:pasteboardOptions];
    //
    //    if ([pasteboardItems count] == 1 && [[pasteboardItems objectAtIndex:0] isKindOfClass:NSString.class])
    //    {
    //    [NSAppDelegate.sharingInterface shareCodeString:[pasteboardItems objectAtIndex:0]];
    //    }
    //    else if ([pasteboardItems count] > 0)
    //    {
    //    [NSAppDelegate.sharingInterface shareCodeFiles:pasteboardItems];
    //    }
    //    return YES;
    //    }
}



