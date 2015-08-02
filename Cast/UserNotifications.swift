//
//  LFNotifications.swift
//  Cast
//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//
import Cocoa

final class UserNotifications: NSObject {
  //---------------------------------------------------------------------------
  var notificationCenter: NSUserNotificationCenter!
  var didActivateNotificationURL: String?
  var timer: NSTimer?
  //---------------------------------------------------------------------------
  override init() {
    super.init()
    notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
    notificationCenter.delegate = self
  }
  //---------------------------------------------------------------------------
  private func createNotification(title: String, subtitle: String) -> NSUserNotification {
    let notification = NSUserNotification()
    notification.title = title
    notification.subtitle = subtitle
    notification.informativeText = "Copied to your clipboard"
    notification.actionButtonTitle = "Open URL"
    notification.soundName = NSUserNotificationDefaultSoundName
    return notification
  }
  //---------------------------------------------------------------------------
  func pushNotification(openURL url: String) {
    didActivateNotificationURL = url
    let notification = self.createNotification("Casted to gist.GitHub.com", subtitle: url)
    notificationCenter.deliverNotification(notification)
    startUserNotificationTimer() //IRC: calling from here doesn't work
  }
  //---------------------------------------------------------------------------
  func pushNotification(error error: String, description: String = "An error occured, please try again.") {
    let notification = NSUserNotification()
    notification.title = error
    notification.informativeText = description
    notification.soundName = NSUserNotificationDefaultSoundName
    notification.hasActionButton = false
    notificationCenter.deliverNotification(notification)
    startUserNotificationTimer()
  }
  //---------------------------------------------------------------------------
  private func startUserNotificationTimer() {
    print(__FUNCTION__)
    self.timer = NSTimer
      .scheduledTimerWithTimeInterval(
        10.0,
        target: self,
        selector: "removeUserNotifcationsAction:",
        userInfo: nil,
        repeats: false)
  }
  //---------------------------------------------------------------------------
  func removeUserNotifcationsAction(timer: NSTimer) {
    print(__FUNCTION__)
    self.notificationCenter.removeAllDeliveredNotifications()
    timer.invalidate()
  }
  //---------------------------------------------------------------------------
}
//MARK:- NSUserNotificationCenterDelegate
extension UserNotifications: NSUserNotificationCenterDelegate {
  //---------------------------------------------------------------------------
  func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
    print("notification pressed")
    if let url = didActivateNotificationURL {
      NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
    } else {
      fatalError("No URL")
    }
  } // executes an action whenever the notification is pressed
  //---------------------------------------------------------------------------
  func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
    return true
  } // forces the notification to display even when app is active app
  //---------------------------------------------------------------------------
}