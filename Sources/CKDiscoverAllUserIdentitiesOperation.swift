//
//  CKDiscoverAllUserIdentitiesOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 14/07/2016.
//
//

import Foundation

public class CKDiscoverAllUserIdentitiesOperation : CKOperation {
    
    var discoveredIdentities: [CKUserIdentity] = []
    
    public override init() {
        super.init()
    }
    
    
    public var userIdentityDiscoveredBlock: ((CKUserIdentity) -> Swift.Void)?
    
    public var discoverAllUserIdentitiesCompletionBlock: ((NSError?) -> Swift.Void)?
    
    override func finishOnCallbackQueueWithError(error: NSError) {
        
        self.discoverAllUserIdentitiesCompletionBlock?(error)
        
        // Mark operation as complete
        self.isExecuting = false
        self.isFinished = true
    }
    
    override func performCKOperation() {
        
        let url = "\(databaseURL)/public/users/discover"
      
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url) { (dictionary, error) in
            
            // Check if cancelled
            if self.isCancelled {
                // Send Cancelled Error to CompletionBlock
                let cancelError = NSError(domain: CKErrorDomain, code: CKErrorCode.OperationCancelled.rawValue, userInfo: nil)
                self.finishOnCallbackQueueWithError(error: cancelError)
            }
            
            if let error = error {
                self.finishOnCallbackQueueWithError(error: error)
                return
            } else if let dictionary = dictionary {
                // Process Records
                if let userDictionaries = dictionary["users"] as? [[String: AnyObject]] {
                    // Parse JSON into CKRecords
                    for userDictionary in userDictionaries {
                        
                        if let userIdenity = CKUserIdentity(dictionary: userDictionary) {
                            self.discoveredIdentities.append(userIdenity)
                            
                            // Call RecordCallback
                            self.userIdentityDiscoveredBlock?(userIdenity)
                            
                        } else {
                            
                            // Create Error
                            let error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: "Failed to parse record from server"])
                            // Call RecordCallback
                            self.finishOnCallbackQueueWithError(error: error)
                            return
                        }
                    }
                }
            }
            
            // Call the final completionBlock
            self.discoverAllUserIdentitiesCompletionBlock?(nil)
           
            // Mark operation as complete
            self.isExecuting = false
            self.isFinished = true
    }
}
}
