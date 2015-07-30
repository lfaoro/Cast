//
//  Global.swift
//  Cast
//
//  Created by Leonardo on 19/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa

public let pasteboardTypes = [NSFilenamesPboardType]

func pushNotification(text: String) {
    let nc = NSUserNotificationCenter.defaultUserNotificationCenter()
    let notification = NSUserNotification()
    notification.title = "Casted to gist.GitHub.com"
    notification.subtitle = text
    notification.informativeText = "Automatically copied to your clipboard"
    notification.actionButtonTitle = "Open"
    nc.deliverNotification(notification)
}