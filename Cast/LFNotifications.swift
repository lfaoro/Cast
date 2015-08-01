//
//  LFNotifications.swift
//  Cast
//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa

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
    //---------------------------------------------------------------------------
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        print("notification pressed")
        if let url = url {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
        }
    } // executes an action whenever the notification is pressed
    //---------------------------------------------------------------------------
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    } // forces the notification to display even when app is active app
    //---------------------------------------------------------------------------
}