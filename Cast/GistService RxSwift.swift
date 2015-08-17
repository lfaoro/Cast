import Cocoa
import SwiftyJSON
import RxSwift
import RxCocoa

enum ConnectionError: ErrorType {
    case InvalidData
    case NoResponse(String)
    case Terrible(String)
}

/**
- TODO: Add OAuth2 towards GitHub as a protocol
- TODO: Store gistID in NSUserDefaults
*/
public final class GistService {
    
    //MARK:- Properties
    let gistAPIURL: NSURL
    var gistID: String?
    
    
    //MARK:- Initialisation
    required init() {
        gistAPIURL = NSURL(string: "https://api.github.com/gists")!
    }
    
    convenience init(baseURL: String) {
        if let url = NSURL(string: baseURL) {
            gistAPIURL = url
        } else {
            print(__FUNCTION__)
            print("Bad URL format, instantiated using default: https://api.github.com/gists")
            gistAPIURL = NSURL(string: "https://api.github.com/gists")!
        }
    }
    
    
    //MARK:- Public API
    public func resetGist() -> Bool {
        self.gistID = nil
        
        return self.gistID == nil
    }
    
    public func setGist(content content: String,
        isPublic: Bool = false, fileName: String = "Casted.swift") // defaults
        -> Observable<(URL: String?, gistID: String?)> {
            
            let gitHubHTTPBody = [
                "description": "Generated with Cast (cast.lfaoro.com)",
                "public": isPublic,
                "files": [fileName: ["content": content]],
            ]
            
            let request: NSMutableURLRequest
            if self.gistUpdate() {
                let updateURL = NSURL(string: self.gistAPIURL.path! + self.gistID!)!
                request = NSMutableURLRequest(URL: updateURL)
                request.HTTPMethod = "PATCH"
            } else {
                request = NSMutableURLRequest(URL: self.gistAPIURL)
                request.HTTPMethod = "POST"
                request.HTTPBody = try! JSON(gitHubHTTPBody).rawData()
            }
            
            return create { observer in
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { (data, response, error) in
                    if let data = data {
                        let jsonData = JSON(data: data)
                        if let url = jsonData["html_url"].string, id = jsonData["id"].string {
                            sendNext(observer, (url, id))
                            sendCompleted(observer)
                        } else {
                            sendError(observer, ConnectionError.InvalidData)
                        }
                    } else {
                        sendError(observer, ConnectionError.NoResponse(error!.localizedDescription))
                    }
                }
                
                task.resume()
                
                return AnonymousDisposable {
                    task.cancel()
                }

            }
            
    }
}