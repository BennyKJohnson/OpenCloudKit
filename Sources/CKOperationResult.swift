//
//  CKOperationResult.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 8/07/2016.
//
//

import Foundation

class CKURLRequest: NSObject, NSURLSessionDataDelegate {
    
    var url: NSURL!
    
    var request: NSURLRequest?
    
    var urlSessionTask: NSURLSessionTask?
    
    var cancelled: Bool = false
    
    func urlSession(_ session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
    }
    
    func urlSession(_ session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
    }
    
    func urlSession(_ session: NSURLSession, dataTask: NSURLSessionDataTask, didReceive response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Swift.Void) {
        
    }
    
    func performRequest() {
        
    }
    
    func setupPublicDatabaseURL() {
        
    }
}
