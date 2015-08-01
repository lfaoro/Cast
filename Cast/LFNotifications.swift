//
//  LFNotifications.swift
//  Cast
//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa

<<<<<<< HEAD


final class LFNotifications: NSObject, NSUserNotificationCenterDelegate {
    //---------------------------------------------------------------------------
    let nc = NSUserNotificationCenter.defaultUserNotificationCenter()
    var url: String?
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
extension LFNotifications {
=======
final class LFNotifications: NSObject {
    //---------------------------------------------------------------------------
    let unc = NSUserNotificationCenter.defaultUserNotificationCenter()
    var url: String?
    var timer: NSTimer?
    //---------------------------------------------------------------------------
    override init() {
        super.init()
        unc.delegate = self
    }
    //---------------------------------------------------------------------------
    func pushNotification(openURL url: String) {
        self.url = url
        let notification = NSUserNotification()
        notification.title = "Casted to gist.GitHub.com"
        notification.subtitle = url
        notification.informativeText = "Copied to your clipboard"
        notification.actionButtonTitle = "Open URL"
        notification.soundName = NSUserNotificationDefaultSoundName
        unc.deliverNotification(notification)
        notifcationTimer()
    }
    //---------------------------------------------------------------------------
    func pushNotification(error error: String, description: String = "An error occured, please try again.") {
        let notification = NSUserNotification()
        notification.title = error
        notification.informativeText = description
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = false
        unc.deliverNotification(notification)
        notifcationTimer()
    }
    //---------------------------------------------------------------------------
    func notifcationTimer() {
        print(__FUNCTION__)
        timer = NSTimer.scheduledTimerWithTimeInterval(
            5.0,
            target: self,
            selector: "removeNotifcationAction:",
            userInfo: nil,
            repeats: true)
    }
    @objc func removeNotifcationAction(timer: NSTimer) {
        print(__FUNCTION__)
        unc.removeAllDeliveredNotifications()
        timer.invalidate()
    }
}
typealias UserNotificationCenterDelegate = LFNotifications
extension UserNotificationCenterDelegate: NSUserNotificationCenterDelegate {
>>>>>>> parent of 28fb214... gcd on caller
    //---------------------------------------------------------------------------
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        print("notification pressed")
        if let url = url {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
        }
<<<<<<< HEAD
    }
=======
    } // executes an action whenever the notification is pressed
    //---------------------------------------------------------------------------
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    } // forces the notification to display even when app is active app
>>>>>>> parent of 28fb214... gcd on caller
    //---------------------------------------------------------------------------
}