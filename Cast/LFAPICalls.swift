//
//  LFShortenURL.swift
//  Cast
//
//  Created by Leonardo on 25/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa

protocol LFAPICallsDelegate {
    func shortened(URL: NSURL?)
}

class LFAPICalls: NSObject {
    
    //---------------------------------------------------------------------------
    
    var delegate: LFAPICallsDelegate?
    let session = NSURLSession.sharedSession()
    
    //---------------------------------------------------------------------------
    
    func shorten(URL: String) {
        
        /// Bit.ly parameters
        let bitlyOAuth2Token = "64192e52f6c12c89942e88ad142796d7caec90cd"
        let bitlyAPIurl = "https://api-ssl.bitly.com"
        
        let bitlyAPIshorten = bitlyAPIurl + "/v3/shorten?access_token=" + bitlyOAuth2Token + "&longUrl=" + URL
        let url: NSURL! = NSURL(string: bitlyAPIshorten)
        //    let request = NSURLRequest(URL: url!)
        //        request.HTTPMethod
        
        let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            if let data = data, response = response {
                print("response: \(response)")
                
                let jsonObj = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                let result = NSURL(string: (jsonObj["data"]!["url"]!! as? String)!)
                self.delegate?.shortened(result)

//                dispatch_async(dispatch_get_main_queue(), {
//                    print("dispatch")
//                    self.delegate?.shortened(result)
//                    
//                })
                
                
            } else {
                print(error)
            }
        }
        
        task.resume()
    }
    
    //---------------------------------------------------------------------------
    
    
    
    
    
    
}