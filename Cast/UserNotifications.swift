//
//  Created by Leonardo on 29/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//


import Cocoa

final class UserNotifications: NSObject {

	var notificationCenter: NSUserNotificationCenter!
	var didActivateNotificationURL: NSURL?

	override init() {
		super.init()
		notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
		notificationCenter.delegate = self
	}

	func createNotification(title: String, subtitle: String) -> NSUserNotification {
		let notification = NSUserNotification()
		notification.title = title
		notification.subtitle = subtitle
		notification.informativeText = "Copied to your clipboard"
		notification.actionButtonTitle = "Open URL"
		notification.soundName = NSUserNotificationDefaultSoundName
		return notification
	}

	func pushNotification(openURL url: String, title: String = "Casted to gist.GitHub.com") {
		didActivateNotificationURL = NSURL(string: url)!
		let notification = self.createNotification(title, subtitle: url)
		notificationCenter.deliverNotification(notification)
		startUserNotificationTimer() //IRC: calling from here doesn't work
	}

	func pushNotification(error error: String,
		description: String = "An error occured, please try again.") {
			let notification = NSUserNotification()
			notification.title = error
			notification.informativeText = description
			notification.soundName = NSUserNotificationDefaultSoundName
			notification.hasActionButton = false
			notificationCenter.deliverNotification(notification)
			startUserNotificationTimer()
	}

	func startUserNotificationTimer() {
		print(__FUNCTION__)
		app.timer = NSTimer
			.scheduledTimerWithTimeInterval(
				5.0,
				target: self,
				selector: "removeUserNotifcationsAction:",
				userInfo: nil,
				repeats: false)
	}

	func removeUserNotifcationsAction(timer: NSTimer) {
		print(__FUNCTION__)
		notificationCenter.removeAllDeliveredNotifications()
		timer.invalidate()
	}

}


extension UserNotifications: NSUserNotificationCenterDelegate {

	func userNotificationCenter(center: NSUserNotificationCenter,
		didActivateNotification notification: NSUserNotification) {
			print("notification pressed")
			if let url = didActivateNotificationURL {
				NSWorkspace.sharedWorkspace().openURL(url)
			} else {
				center.removeAllDeliveredNotifications()
			}
	}

	func userNotificationCenter(center: NSUserNotificationCenter,
		shouldPresentNotification notification: NSUserNotification) -> Bool {
			return true
	}
	
}
