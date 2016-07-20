//
//  CKPushConnection.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 15/07/2016.
//
//

import Foundation
/*
class CKPushConnection: NSObject, URLSessionDataDelegate {

    var longPollingTask: URLSessionDataTask?
    
    func establishConnection(with url: URL) {
        
        let urlRequest = URLRequest(url: url)
      
        longPollingTask = URLSession.shared.dataTask(with: urlRequest)
        
        longPollingTask?.resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        // Create Notification
        
        
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            print(error)
        }
        
        // Restart Task
        longPollingTask?.resume()
    }
    
  
}
*/