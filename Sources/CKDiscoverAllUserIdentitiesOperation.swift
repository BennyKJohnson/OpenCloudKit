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
    
    public var discoverAllUserIdentitiesCompletionBlock: ((Error?) -> Swift.Void)?
    
    override func finishOnCallbackQueue(error: Error?) {
        
        self.discoverAllUserIdentitiesCompletionBlock?(error)
        
        super.finishOnCallbackQueue(error: error)
    }
    
    
    override func performCKOperation() {
        
        let url = "\(databaseURL)/public/users/discover"
      
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url) { (dictionary, error) in
            
            // Check if cancelled
            // (Should no longer be needed)
//            if self.isCancelled {
//                // Send Cancelled Error to CompletionBlock
//                let cancelError = NSError(domain: CKErrorDomain, code: CKErrorCode.OperationCancelled.rawValue, userInfo: nil)
//                self.finishOnCallbackQueue(error: cancelError)
//            }
//            
            if let error = error {
                self.finish(error: error)
                return
            } else if let dictionary = dictionary {
                // Process Records
                if let userDictionaries = dictionary["users"] as? [[String: Any]] {
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
                            self.finish(error: error)
                            return
                        }
                    }
                }
            }
            
            // Mark operation as complete
            self.finish(error: nil)
    }
}
}
