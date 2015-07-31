//
//  LFNotifications.swift
//  Cast
//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa



final class LFNotifications: NSObject, NSUserNotificationCenterDelegate {
    let nc = NSUserNotificationCenter.defaultUserNotificationCenter()
    var url: String?
    //---------------------------------------------------------------------------
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        print("notification pressed")
        if let url = url {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
        }
    }
    //---------------------------------------------------------------------------
    func pushNotification(text: String) {
        self.url = text
        let notification = NSUserNotification()
        notification.title = "Casted to gist.GitHub.com"
        notification.subtitle = text
        notification.informativeText = "Automatically copied to your clipboard"
        notification.actionButtonTitle = "Open URL"
        notification.soundName = NSUserNotificationDefaultSoundName
        nc.delegate = self
        nc.deliverNotification(notification)
    }
    //---------------------------------------------------------------------------
}