~~~
[Globals]
createStatusBar
-configureStatusBarItem
-createMenu

[AppDelegate]
@statusBarItem: NSStatusItem!
@menuSendersAction: MenuSendersAction!
@webAPI: WebAPIs!
@userNotification: UserNotifications!
@options: Options!
-applicationWillFinishLaunching
-applicationDidFinishLaunching
-updateMenu

[MenuSendersAction]
@pasteboard
-shareClipboardContentsAction
-recentUploadsAction
-clearItemsAction
-startAtLoginAction
-openOptionsWindow

[WebAPI]
@session
@textExcerpt
-share
-shortenURL
-uploadTextData

[PasteboardController]
@pasteboard
@classes[:]
-extractData
-copyToClipboard

[UserNotifications]
@notificationCenter
@didActivateNotificationURL
@timer
-init
-createNotification
-pushNotification(openURL)
-pushNotification(error)
-startUserNotificationTimer
-removeUserNotifcationsAction

[@NSUserNotificationCenterDelegate]
-didActivateNotification
-shouldPresentNotification
