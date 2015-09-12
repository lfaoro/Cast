# ![Cast logo](https://raw.githubusercontent.com/lfaoro/Cast/master/Cast/Assets.xcassets/AppIcon.appiconset/64x64.png) Cast | share data, quick & easy

[![release](https://img.shields.io/badge/release-v1.0-green.svg)](https://github.com/lfaoro/Cast/releases)
[![platform](https://img.shields.io/badge/platform-OS%20X%2010.10+-lightgrey.svg)](https://www.apple.com/osx/)
[![license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/lfaoro/Cast/blob/master/LICENSE.md)
[![twitter](https://img.shields.io/badge/twitter-%40leonarth-blue.svg)](https://twitter.com/leonarth)

*// Cast: verb. throw (something) forcefully in a specified direction.*

Cast is an agent that lives in your system's
[Status Menu](https://support.apple.com/en-mt/HT201956).
Its purpose is to help you share information quick & easy.

Cast will seamlessly figure out the type of information you wish to share and automatically choose the appropriate service for you. You may customize the sharing service you wish to use from a selection of available services.

Cast will also help you shorten URLs very quickly using your preferred URL shortening service.

~~Cast can queue up multiple streams of information and share them all at once extending the system's Pasteboard functionality~~

## Features available in v1.0
- [x] Uploads data automatically
- [x] Creates shortened download link
- [x] The shortened link is automatically moved inside your Pasteboard (ready to paste)
- [x] System Notification alerts displaying links or errors
- [x] Ability to click on the Notification and open the link
- [x] Seamless OAuth2 Web-Flow authentication to GitHub.com (no password)
- [x] GitHub's access Token securely stored inside your [Keychain](https://en.wikipedia.org/wiki/Keychain_(software))
- [x] Uploads raw text to the gist service creating a new gist
- [x] Uploads raw text to the gist service updating current gist (incremental/revisions)
- [x] Shortens any URL and prepares the shortened link in your Pasteboard (ready to paste)
- [x] Keeps a History of all your uploads and URL shorts
- [x] Clicking a recent upload from the list, open it in your default browser
- [ ] Recent upload links synced via iCloud across all your Macs
- [ ] Configure the app through the Options menu

## Features roadmap for v2.0

- [ ] Seamless OAuth2 Web-Flow authentication to imgur.com (no password)
- [ ] Uploads images to imgur.com
- [ ] Uploads folders to iCloud Disk
- [ ] Automatically ZIPs folders before upload
- [ ] Multiple uploads in one operation functionality
- [ ] Pasteboard queue functionality
- [ ] Incremental Pasteboard functionality
- [ ] Send Pasteboard contents as email without opening Mail.app

## Supported Services
*As of release 1.0 Cast supports the following sharing services:*

**Text data** extracted from your pasteboard
- [x] [gist.github.com](http://gist.github.com)
- [ ] ~~pastebin.com~~ (too many ads)
- [ ] [dpaste.com](http://dpaste.com)
- [ ] [swiftstub.com](http://swiftstub.com)

**Image data** extracted from your pasteboard
- [ ] [imgur.com](http://imgur.com)
- [ ] [flickr.com](http://flickr.com)

**Folders and Files** which will be automatically zipped for you before uploading
- [ ] [iCloud Drive](http://www.apple.com/icloud/icloud-drive/)
- [ ] wetransfer.com
- [ ] dropbox.com

**URL Shorteners**
- [x] [hive.am](www.hive.am)
- [x] bit.ly
- [x] is.gd

## Development Requirements
- OS X 10.10 Yosemite or newer
- Xcode 7
- Swift 2.0
- [Carthage][128c6379]
- [SwiftLint][9afd067e] (used in a Run Script Phase)

  [128c6379]: https://github.com/Carthage/Carthage#installing-carthage "Install Carthage"
  [9afd067e]: https://github.com/realm/SwiftLint#installation "Install SwiftLint"

## Contributing

> We use [gitflow][0d3b04ed], please fork and push your enhancements to the `develop` branch

```Bash
git checkout develop
carthage bootstrap
open Cast.xcodeproj
```
Please, pick an [Issue][c2a6348a] and submit a pull request.
Thank you very much for any contribution!

  [c2a6348a]: https://github.com/lfaoro/Cast/issues "Push to `develop` please"
  [0d3b04ed]: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow "Gitflow Workflow"


## Communication
- If you **need help**, [send me a tweet](<https://twitter.com/leonarth>)
- If you'd like to **ask a general question**, [send me a tweet](<https://twitter.com/leonarth>)
- If you **found a bug**, [open an issue](<https://github.com/lfaoro/Cast/issues>)
- If you **have a feature request**, [open an issue](<https://github.com/lfaoro/Cast/issues>)
- If you'd **like to contribute** compile Cast and look at the `Issue Navigator` (⌘+4) a script will outline all the `//TODO:` statements present in the source files.

## Credits

> We all stand on the shoulders of giants across many open source communities. I’d like to thank the communities and projects that every day establish our inspiration.

## Security Disclosure
If you believe you have identified a security vulnerability with Cast, you should report it as soon as possible via email to security@lfaoro.com. Please do not post it to a public issue tracker.

## License
Cast is released under the [MIT License](<LICENSE.md>)
