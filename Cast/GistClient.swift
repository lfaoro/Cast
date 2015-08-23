import Cocoa
import SwiftyJSON
import RxSwift
import RxCocoa

public enum ConnectionError: ErrorType {
    case InvalidData(String), NoResponse(String), NotAuthenticated(String), StatusCode(Int)
}

/**
GistService: is a wrapper around the gist.github.com service API.

An instance of GistService allows you login via OAuth with your GitHub account or remain anonymous.

You may create new gists as anonymous but you may modify a gist only if you're logged into the service.
*/
public class GistClient {
    
    //MARK:- Properties
    private static let defaultURL = NSURL(string: "https://api.github.com/gists")!
    public let gistAPIURL: NSURL
    let oauth: OAuthClient
    var gistID: String? {
        get {
            if OAuthClient.getToken() != nil {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                return userDefaults.stringForKey("gistID")
            } else {
                return nil
            }
        }
        set (value) {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(value, forKey: "gistID")
        }
    }
    
    
    //MARK:- Initialisation
    public init(baseURL: NSURL = defaultURL) {
        self.gistAPIURL = baseURL
        
        self.oauth = OAuthClient(
            clientID: "ef09cfdbba0dfd807592",
            clientSecret: "ce7541f7a3d34c2ff5b20207a3036ce2ad811cc7",
            service: .GitHub
        )!
    }
    
    /**
    Used for Unit Tests purposes only, this API doesn't support any other service
    except `gist.github.com`
    */
    public convenience init?(baseURLString: String) {
        if let baseURL = NSURL(string: baseURLString) {
            self.init(baseURL: baseURL)
        } else {
            print(__FUNCTION__)
            print("URL not conforming to RFCs 1808, 1738, and 2732 formats")
            return nil
        }
    }
    
    
    //MARK:- Public API
    /**
    setGist: creates or updates a gist on the *gist.github.com* service
    based on the value of `gistID`.
    
    - returns: an `Observable` object containing the URL link of the created gist - for more information checkout
    [RxSwift](https://github.com/ReactiveX/RxSwift)
    
    ![RxLogo](http://reactivex.io/assets/Rx_Logo_BW_S.png)
    */
    public func setGist(content content: String, updateGist: Bool = true,
        isPublic: Bool = false, fileName: String = "Casted.swift") // defaults
        -> Observable<NSURL> {
            
            return create { stream in
                
                let githubHTTPBody = [
                    "description": "Generated with Cast (cast.lfaoro.com)",
                    "public": isPublic,
                    "files": [fileName: ["content": content]],
                ]
                
                var request: NSMutableURLRequest
                if let gistID = self.gistID where updateGist {
                    let updateURL = self.gistAPIURL.URLByAppendingPathComponent(gistID)
                    request = NSMutableURLRequest(URL: updateURL)
                    request.HTTPMethod = "PATCH"
                    
                    if let token = OAuthClient.getToken() {
                        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
                    }
                    
                } else {
                    request = NSMutableURLRequest(URL: self.gistAPIURL)
                    request.HTTPMethod = "POST"
                }
                request.HTTPBody = try! JSON(githubHTTPBody).rawData()
                request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
                
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { (data, response, error) in
                    if let data = data, response = response as? NSHTTPURLResponse {
                        
                        if !((200..<300) ~= response.statusCode) {
                            sendError(stream, ConnectionError.StatusCode(response.statusCode))
                            print(response)
                        }
                        
                        let jsonData = JSON(data: data)
                        if let gistURL = jsonData["html_url"].URL, gistID = jsonData["id"].string {
                            
                            self.gistID = gistID
                            
                            sendNext(stream, gistURL)
                            sendCompleted(stream)
                            
                        } else {
                            sendError(stream, ConnectionError.InvalidData("Unable to read data received from \(self.gistAPIURL)"))
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