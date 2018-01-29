//
//  CKPushConnection.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 15/07/2016.
//
//

import Foundation

class CKPushConnection: NSObject, URLSessionDataDelegate {

    var longPollingTask: URLSessionDataTask?
    
    var callBack: ((CKNotification) -> Void)?
    
    init(url: URL) {
        
        super.init()
        
        let urlRequest = URLRequest(url: url)
        
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = Double.greatestFiniteMagnitude
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        longPollingTask = session.dataTask(with: urlRequest)
        
        longPollingTask?.resume()
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        // Serialize JSON
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                CloudKit.debugPrint(json)
                // Create Notification
                if let notification = CKNotification.notification(fromRemoteNotificationDictionary: json) {
                    callBack?(notification)
                }
                /*
                if let notification = CKNotification(fromRemoteNotificationDictionary: json) {
                    callBack?(notification)
                }
 */
            }
        } catch {
            
        }
        
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            CloudKit.debugPrint(error)
        }
        
        // Restart Task
        longPollingTask?.resume()
    }
    
  
}
