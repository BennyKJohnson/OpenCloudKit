//
//  CKModifySubscriptionsOperation.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 12/07/2016.
//
//

import Foundation

public class CKModifySubscriptionsOperation : CKDatabaseOperation {
    
    public init(subscriptionsToSave: [CKSubscription]?, subscriptionIDsToDelete: [String]?) {
        super.init()
        
        self.subscriptionsToSave = subscriptionsToSave
        self.subscriptionIDsToDelete = subscriptionIDsToDelete
    }
    
    public var subscriptionsToSave: [CKSubscription]?
    public var subscriptionIDsToDelete: [String]?
    
    /*  This block is called when the operation completes.
     The [NSOperation completionBlock] will also be called if both are set.
     If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
     a dictionary of subscriptionIDs to errors keyed off of CKPartialErrorsByItemIDKey.
     */
    public var modifySubscriptionsCompletionBlock: (([CKSubscription]?, [String]?, Error?) -> Void)?
    
  
    override func performCKOperation() {
        
        let subscriptionURLRequest = CKModifySubscriptionsURLRequest(subscriptionsToSave: subscriptionsToSave, subscriptionIDsToDelete: subscriptionIDsToDelete)
        subscriptionURLRequest.completionBlock = {
            (result) in
            switch result {
            case .success(let dictionary):
                
                if let subscriptionsDictionary = dictionary["subscriptions"] as? [[String: Any]] {
                    // Parse JSON into CKRecords
                    var subscriptions: [CKSubscription] = []
                    var deletedSubscriptionIDs: [String] = []
                    
                    for subscriptionDictionary in subscriptionsDictionary {
                        
                        if let subscription = CKSubscription(dictionary: subscriptionDictionary) {
                            // Append Record
                            subscriptions.append(subscription)
                            
                        } else if let subscriptionID = subscriptionDictionary["subscriptionID"] as? String {
                            deletedSubscriptionIDs.append(subscriptionID)
                            
                        } else if let subscriptionFetchError = CKSubscriptionFetchErrorDictionary(dictionary: subscriptionDictionary) {
                            
                            // Create Error
                            let error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: subscriptionFetchError.reason])
                            
                            self.modifySubscriptionsCompletionBlock?(nil, nil, error)
                            
                        } else {
                            fatalError("Couldn't resolve record or record fetch error dictionary")
                        }
                    }
                    
                    self.modifySubscriptionsCompletionBlock?(subscriptions, deletedSubscriptionIDs, nil)
                }
                
                
            case .error(let error):
                self.modifySubscriptionsCompletionBlock?(nil, nil, error.error)

            }
            self.finish()
        }
        
        subscriptionURLRequest.performRequest()
    }
}
