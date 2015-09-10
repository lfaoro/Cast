# ![Cast logo](https://raw.githubusercontent.com/lfaoro/Cast/master/Cast/Assets.xcassets/AppIcon.appiconset/64x64.png) Cast | share data, securely, the easy way

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/lfaoro/Cast/blob/master/LICENSE.md)
[![release](https://img.shields.io/badge/release-BETA-red.svg)](https://github.com/lfaoro/Cast/releases)
[![platform](https://img.shields.io/badge/platform-Mac%20OS%20X%2010.9%2B-lightgrey.svg)](https://www.apple.com/osx/)
[![twitter](https://img.shields.io/badge/twitter-%40leonarth-blue.svg)](https://twitter.com/leonarth)

*// Cast: verb. throw (something) forcefully in a specified direction.*

Cast is an agent that lives in your system's
[Status Menu](https://support.apple.com/en-mt/HT201956).
Its purpose is to help you share any type of information quickly and easily with a  keyboard shortcut, a 1-click or drag'n'drop
operation.

Cast will seamlessly figure out the type of information you wish to share and
automatically choose the appropriate service for you. You may customize the
service you wish to use from a selection of available services.

Cast can queue up multiple streams of information and share them all at once 
extending the system's Pasteboard functionality 

## Features roadmap for v1.0
- [x] Uploads data automatically
- [x] Creates shortened download link using [bit.ly](https://bitly.com/)
- [x] The shortened link is automatically moved inside your Pasteboard (ready to paste)
- [x] Notification alerts containing links or errors
- [x] Ability to click on the Notification and open the link
- [x] Seamless OAuth2 Web-Flow authentication to GitHub.com (no password)
- [x] GitHub's access Token securely stored inside your [Keychain](https://en.wikipedia.org/wiki/Keychain_(software))
- [x] Uploads raw text to the gist service creating a new gist
- [x] Uploads raw text to the gist service updating current gist (incremental/revisions)
- [ ] Up to 20 recent upload links
- [ ] Recent upload links synced via iCloud across all your Macs
- [ ] Configure the app through the Options menu

## Features roadmap for future versions 2.0+

- [ ] Seamless OAuth2 Web-Flow authentication to Imgur.com (no password)
- [ ] Uploads images to imgur
- [ ] Uploads folders to iCloud Disk
- [ ] Automatically ZIPs folders before upload
- [ ] Multiple uploads in one operation functionality
- [ ] Pasteboard queue functionality
- [ ] Incremental Pasteboard functionality

## Supported Services 
*As of release 1.0 Cast will support the following sharing services:*

**Text data** extracted from your pasteboard
- [x] gist.github.com
- [ ] pastebin.com
- [ ] dpaste.com
- [ ] swiftstub.com

**Image data** extracted from your pasteboard
- [ ] imgur.com
- [ ] flickr.com

**Folders** which will be automatically zipped for you before uploading 
- [ ] icloud
- [ ] wetransfer.com
- [ ] dropbox.com

**URL Shorteners**
- [x] bit.ly

## Requirements
- OS X 10.9+
- Xcode 7

## Communication
- If you **need help**, [send me a tweet](<https://twitter.com/leonarth>)
- If you'd like to **ask a general question**, [send me a tweet](<https://twitter.com/leonarth>)
- If you **found a bug**, [open an issue](<https://github.com/lfaoro/Cast/issues>)
- If you **have a feature request**, [open an issue](<https://github.com/lfaoro/Cast/issues>)
- If you'd **like to contribute**, check the [system map](https://github.com/lfaoro/Cast/blob/master/SystemMap.md) and look for TODO: statements in the source files.

## Credits
> Cast is owned and maintained by [Leonardo Faoro](http://cv.lfaoro.com) and his mentor and friend [Chris Patrick Schreiner](https://www.linkedin.com/in/chrispschreiner).

> We all stand on the shoulders of giants across many open source communities. We’d like to thank the communities and projects that established our inspiration.

## Security Disclosure
If you believe you have identified a security vulnerability with Cast, you should report it as soon as possible via email to security@lfaoro.com. Please do not post it to a public issue tracker.

## License
Cast is released under the [MIT License](<LICENSE.md>)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/lfaoro/cast/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

