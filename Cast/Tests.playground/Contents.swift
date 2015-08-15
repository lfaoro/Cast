//: Playground - noun: a place where people can play

import Cocoa
import SwiftyJSON
import ReactiveCocoa
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely(true)

enum ConnectionError: ErrorType {
    case Bad(String)
    case Worse(String)
    case Terrible(String)
}

enum SomeError:ErrorType {
    case ShitHappened
}

func maker() -> SignalProducer<String,SomeError> {
    let text = "textType"
    return SignalProducer { sink,disp in
        //hwne you have some data to give back
        sendNext(sink, text)
        sendNext(sink, "some more data in text")
        sendCompleted(sink)
        //        sendError(sink,SomeError.ShitHappened)
    }
}

let m = maker()
    //.on(next:print)
    .on(completed:{print("We comelteded")})
//.on(error:print)

//dead pipeline
m.start(next:{print($0)}, error:print)

//this pipeline will stay dead until started with .start()
let pipeline = m
    .map{$0.uppercaseString}
    .on(next:{print("just got at \($0)")})

for n in 0...100 {
    pipeline.start() //sp has to be started
}

//pipeline is a parameter


func postRequest(content content: String, isUpdate: Bool, URL: NSURL,
    isPublic: Bool = false, fileName: String = "Casted.swift") -> SignalProducer<(URL: NSURL, gistID: String), ConnectionError> {
        
        return SignalProducer {sink, disp in
        
        let gistID = "123456"
        let gitHubHTTPBody = [
            "description": "Generated with Cast (cast.lfaoro.com)",
            "public": isPublic,
            "files": [fileName: ["content": content]],
        ]
        
        let request: NSMutableURLRequest
        if isUpdate {
            let updateURL = NSURL(string: URL.path! + gistID)!
            request = NSMutableURLRequest(URL: updateURL)
            request.HTTPMethod = "PATCH"
        } else {
            request = NSMutableURLRequest(URL: URL)
            request.HTTPMethod = "POST"
            request.HTTPBody = try! JSON(gitHubHTTPBody).rawData()
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if let data = data {
                let jsonData = JSON(data: data)
                if let url = jsonData["url"].URL, id = jsonData["id"].string {
                    sendNext(sink, (url, id))
                    sendCompleted(sink)
                } else {
                    sendError(sink, ConnectionError.Bad("URL or ID Invalid"))
                }
            } else {
                sendError(sink, ConnectionError.Worse(error!.localizedDescription))
            }
        }
        task.resume()
        }
}

postRequest(content: "ciao", isUpdate: false, URL: NSURL(string: "https://api.github.com/gists")!)
    .on(next: print)
    .on(error: { print($0) })
    .on(completed: { print("completed") })
    .start()






