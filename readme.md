What is Cast?
-------------

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

### System map

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AppDelegate
@ statusBar (awakeFromNib)

ViewController
@ clipboardType: ClipboardThing
@ configuration: ConfigureServiceForClipboardType
@ apiCall (viewDidLoad)
@ Queue
- shortenAsync -> NSURL //what do I produce?

TraditionalAsyncThing:ViewController
- process1

ReactiveCocoaThing:ViewController
- reactiveCocoaCall -> SignalProducer<NSURL,MyErrors>
- process2

LFStatusBar
@ statusBarItem
@ recentUploads
- displayStatusBarItem -> Void //should this be void!!!
- createMenu -> NSMenu

LFAPICalls

TraditionalAsyncExtension: LFAPICalls
- shortenUrl // shortens URLs
    +.configuration.serviceFor(ClipboardType)
- uploadText(String) // uploads text to gisthub,pastebin,swiftshare,

ClipboardContent
- clipboardType(Input): ClipboardType

ConfigureServiceForClipboardType //{Select appropriate service for clipboard-type}
- serviceFor(ClipboardType)
    +.clipboardType.clipboardType(...)

Queue
- add(ClipboardContent) //add stuff to the queue, and when you're done 
- performOnAll(some-service) -> [NSURL] //call this from the menu

SignalProducerExtension: LFAPICalls
- shortenProducer(NSURL) -> SignalProducer<NSURL,MyErrors>
- uploadText(String) -> SignalProducer<NSURL,MyError> //like a machine, that produces NSURL from a String (which is text)
   +get text from clipboard
   +sends post request to ConfigureServiceForClipboardType with contents -> NSURL | shortenProducer

ServiceProviderURLs: String
- asBitlyURL

MyErrors
* NoNetworkAccess
* ServiceError  //gist was down, couldn't upload to it
* UnrecognizedClipboardType
* ClipboardIsEmpty
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#### Some profound words about our custom markup

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IAmAClass: ThatExtendsAnother
@ andThisIsAProperty (important context where I’m used)
- andHereWeHaveAMethod -> ThatReturnsAType
- secondMethod -> Void //a comment about that
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#### Todo

1.  Implement the gisthub-type for plain text.

2.  How to extract text from the clipboard

3.  How to clear the clipboard

4.  Implement the gist api we need.

#### Future

1.  Implement the paste-bin api
