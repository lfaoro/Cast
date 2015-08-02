//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

// Cast: verb. throw (something) forcefully in a specified direction.

import Cocoa


final class MenuSendersAction: NSObject {
    //MARK:- NSMenuItem selectors
    func shareClipboardContentsAction(sender: NSMenuItem) {
        app.api.share()
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
            app.updateMenu()
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
 