[*Global*]
-createStatusBar
-configureStatusBarItem
-createMenu
[AppDelegate]
@statusBarItem: NSStatusItem!
 var menuSendersAction: MenuSendersAction!
 var webAPI: WebAPIs!
 var userNotification: UserNotifications!
 var options: Options!
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