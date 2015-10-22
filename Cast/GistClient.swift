//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa
import SwiftyJSON
import RxSwift
import RxCocoa


public enum ConnectionError: ErrorType {
    case InvalidData(String), NoResponse(String), NotAuthenticated(String), StatusCode(Int)
}


public enum GistService {
    case GitHub, PasteBin
}


public class GistOptions {


    private let githubAPI = NSURL(string: "https://api.github.com/gists")!
    private let pastebinAPI = NSURL(string: "https://api.pastebin.com/gists")!

    public var gistService: GistService = .GitHub
    public var publicGist: Bool = false
    public var fileName: String = "Casted.swift"
    public var description: String = "Generated with Cast (cast.lfaoro.com)"

    // This can't be set unless the user is logged in
    private var gistIsUpdatable: Bool = false
    public var updateGist: Bool {
        get {
            if gistID != nil && gistIsUpdatable == true {
                return true
            } else {
                return false
            }
        }
        set {
            gistIsUpdatable = newValue
        }
    }

    private var connectionURL: NSURL {
        get {
            switch gistService {
            case .GitHub:
                return githubAPI
            case .PasteBin:
                return pastebinAPI
            }
        }
    }

    var gistID: String? {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if OAuthClient.getToken() != nil {
                return userDefaults.stringForKey("gistID")
            } else {
                userDefaults.removeObjectForKey("gistID")
                return nil
            }
        }
        set {
            if OAuthClient.getToken() != nil {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(newValue, forKey: "gistID")
            }
        }
    }
}


public class GistClient {
    var options: GistOptions


    required public init(options: GistOptions) {
        self.options = options
    }


    public func createGist(content: String) -> ErrorType? {
        let shortenClient = ShortenClient()

        self.setGist(content: content)
        .debug("setGist")
        .retry(3)
        .flatMap {
            shortenClient.shorten(URL: $0)
        }
        .subscribe {
            event in
            switch event {

            case .Next(let URL):
                if let URL = URL {
                    putInPasteboard(items: [URL])
                    app.userNotification.pushNotification(openURL: URL)
                } else {
                    app.userNotification.pushNotification(error: "Unable to Shorten URL")
                }

            case .Completed: break
                    //								app.statusBarItem.menu = createMenu(self)

            case .Error(let error):
                app.userNotification.pushNotification(error: String(error))
            }
        }

        return nil
    }

    func setGist(content content: String) // defaults
                    -> Observable<NSURL> {

        let HTTPBody = [
                "description": self.options.description,
                "public": self.options.publicGist,
                "files": [self.options.fileName: ["content": content]],
        ]


        return create {
            stream in
            var request: NSMutableURLRequest

            switch self.options.updateGist {

            case true:
                let updateURL = self.options.connectionURL
                .URLByAppendingPathComponent(self.options.gistID!)
                request = NSMutableURLRequest(URL: updateURL)
                request.HTTPMethod = "PATCH"

            case false:
                request = NSMutableURLRequest(URL: self.options.connectionURL)
                request.HTTPMethod = "POST"
            }
            request.HTTPBody = try! JSON(HTTPBody).rawData()
            request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
            if let token = OAuthClient.getToken() {
                request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
            }

            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) {
                (data, response, error) in
                if let data = data, response = response as? NSHTTPURLResponse {

                    if !((200 ..< 300) ~= response.statusCode) {
                        sendError(stream, ConnectionError.StatusCode(response.statusCode))
                        print(response)
                    }

                    let jsonData = JSON(data: data)
                    if let gistURL = jsonData["html_url"].URL, gistID = jsonData["id"].string {

                        self.options.gistID = gistID

                        sendNext(stream, gistURL)
                        sendCompleted(stream)

                    } else {
                        sendError(stream, ConnectionError.InvalidData(
                        "Unable to read data received from \(self.options.connectionURL)"))
                    }
                } else {
                    sendError(stream, ConnectionError.NoResponse(error!.localizedDescription))
                }
            }

            task.resume()

            return NopDisposable.instance
        }
    }
}
