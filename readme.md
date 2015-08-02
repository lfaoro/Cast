What is Cast?
=============

*// Cast: verb. throw (something) forcefully in a specified direction.*

Cast is an agent that lives in your system’s status bar. It’s purpose is to help
you share any type of information quickly and easily with a drag’n’drop
operation or a keyboard shortcut.

Cast will seamlessly figure out the type of information you wish to share and
automatically choose the appropriate service for you. You may customize the
service you wish to use through a list of available services.

Cast can queue up multiple streams of information and share them all at once.

Cast supports these information types and services and we’re working on
supporting more:

-   Text data either copied to your clipboard or contained in a file -  
    shared with:

    -   gist.github.com

    -   pastebin.com

-   Image data either copied to your clipboard or contained in a file -  
    shared with:

    -   imgur.com

    -   flickr.com

-   Folders which will be automatically zipped for you before uploading -  
    shared with:

    -   icloud

    -   wetransfer.com

    -   dropbox.com

System map
----------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[AppDelegate]
@ statusBar = LFStatusBar()
@ api = LFWebAPIs()
@ pasteboard = LFPasteboard()
@ userNotification = LFUserNotifications()

[LFStatusBar]
@ statusBarItem = NSStatusItem
- displayStatusBarItem -> Void //should this be void!!! // what else should it be???
- createMenu -> NSMenu
// selector Actions
- shareClipboardContentsAction()
- recentUploadsAction()
- clearItemsAction()
- startAtLoginAction()

[LFWebAPIs]
@ session = NSURLSession


ServiceProviderURLs: String
- asBitlyURL

MyErrors
* NoNetworkAccess
* ServiceError  //gist was down, couldn't upload to it
* UnrecognizedClipboardType
* ClipboardIsEmpty
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some profound words about our custom markup
-------------------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IAmAClass: ThatExtendsAnother
@ andThisIsAProperty (important context where I’m used)
- andHereWeHaveAMethod -> ThatReturnsAType
- secondMethod -> Void //a comment about that
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Todo
----

Please check the list of open issues on GitHub: [Open
issues](<https://github.com/lfaoro/Cast/issues>)
