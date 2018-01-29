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
    
    var subscriptions: [CKSubscription] = []
    var deletedSubscriptionIDs: [String] = []
    var subscriptionErrors: [String: NSError] = [:] // todo needs filled up with the errors
    
    /*  This block is called when the operation completes.
     The [NSOperation completionBlock] will also be called if both are set.
     If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
     a dictionary of subscriptionIDs to errors keyed off of CKPartialErrorsByItemIDKey.
     */
    public var modifySubscriptionsCompletionBlock: (([CKSubscription]?, [String]?, Error?) -> Void)?
    
    override func finishOnCallbackQueue(error: Error?) {
        var error = error
        if(error == nil){
            if subscriptionErrors.count > 0 {
                error = CKPrettyError(code: CKErrorCode.PartialFailure, userInfo: [CKPartialErrorsByItemIDKey : subscriptionErrors], description: "Errors modifying subscriptions")
            }
        }
        self.modifySubscriptionsCompletionBlock?(subscriptions, deletedSubscriptionIDs, error)
        
        super.finishOnCallbackQueue(error: error)
    }
    
    override func performCKOperation() {
        
        let subscriptionURLRequest = CKModifySubscriptionsURLRequest(subscriptionsToSave: subscriptionsToSave, subscriptionIDsToDelete: subscriptionIDsToDelete)
        subscriptionURLRequest.completionBlock = { [weak self] (result) in
            guard let strongSelf = self, !strongSelf.isCancelled else {
                return
            }
            switch result {
            case .success(let dictionary):
                
                if let subscriptionsDictionary = dictionary["subscriptions"] as? [[String: Any]] {
                    // Parse JSON into CKRecords
                    
                    
                    for subscriptionDictionary in subscriptionsDictionary {
                        
                        if let subscription = CKSubscription(dictionary: subscriptionDictionary) {
                            // Append Record
                            strongSelf.subscriptions.append(subscription)
                            
                        } else if let subscriptionID = subscriptionDictionary["subscriptionID"] as? String {
                            strongSelf.deletedSubscriptionIDs.append(subscriptionID)
                            
                        } else if let subscriptionFetchError = CKSubscriptionFetchErrorDictionary(dictionary: subscriptionDictionary) {
                            
                            // Create Error
                            let _ = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: subscriptionFetchError.reason])
                            
                            // todo add to errors
                            //subscriptionErrors["id"] = error
                            
                        } else {
                            fatalError("Couldn't resolve record or record fetch error dictionary")
                        }
                    }
                }
                
                strongSelf.finish(error: nil)
            case .error(let error):
                strongSelf.finish(error: error.error)
            }
        }
        
        subscriptionURLRequest.performRequest()
    }
}
