//
//  CKFetchSubscriptionsOperation.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 13/07/2016.
//
//

import Foundation

public class CKFetchSubscriptionsOperation : CKDatabaseOperation {
    
    public override required init() {
        super.init()
    }
    
    public class func fetchAllSubscriptionsOperation() -> Self {
        let operation = self.init()
        return operation
    }
    
    public convenience init(subscriptionIDs: [String]) {
        self.init()
        self.subscriptionIDs = subscriptionIDs
    }
    
    public var subscriptionIDs: [String]?
    
    /*  This block is called when the operation completes.
     The [NSOperation completionBlock] will also be called if both are set.
     If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
     a dictionary of subscriptionID to errors keyed off of CKPartialErrorsByItemIDKey.
     */
    public var fetchSubscriptionCompletionBlock: (([String : CKSubscription]?, NSError?) -> Void)?
    
    override func performCKOperation() {
        
        let url = "\(operationURL)/subscriptions/lookup"
        
        var request: [String: AnyObject] = [:]
        if let subscriptionIDs = subscriptionIDs {
            request["subscriptions"] = subscriptionIDs
        }
        
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url, parameters: request) { (dictionary, networkError) in
            if let error = networkError {
                
                self.fetchSubscriptionCompletionBlock?(nil, error)
                
            } else if let dictionary = dictionary {
                
                if let subscriptionsDictionary = dictionary["subscriptions"] as? [[String: AnyObject]] {
                    // Parse JSON into CKRecords
                    var subscriptionsIDToSubscriptions: [String: CKSubscription] = [:]
                    var subscriptionErrorIDs: [String: NSError] = [:]
                    
                    for subscriptionDictionary in subscriptionsDictionary {
                        
                        if let subscription = CKSubscription(dictionary: subscriptionDictionary) {
                            // Append Record
                            subscriptionsIDToSubscriptions[subscription.subscriptionID] = subscription
                            
                        }  else if let subscriptionFetchError = CKSubscriptionFetchErrorDictionary(dictionary: subscriptionDictionary) {
                           
                            let errorCode = CKErrorCode.errorCode(serverError: subscriptionFetchError.serverErrorCode)!
                            let error = NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: [NSLocalizedDescriptionKey: subscriptionFetchError.reason])
                            
                            subscriptionErrorIDs[subscriptionFetchError.subscriptionID] = error
                            
                        } else {
                            fatalError("Couldn't resolve record or record fetch error dictionary")
                        }
                    }
                    
                    let partialError: NSError?
                    if subscriptionErrorIDs.isEmpty {
                        partialError = nil
                    } else {
                        
                        partialError = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo:
                            [NSLocalizedDescriptionKey: "Partial Error",
                             CKPartialErrorsByItemIDKey: subscriptionErrorIDs])
                    }
                    
                    self.fetchSubscriptionCompletionBlock?(subscriptionsIDToSubscriptions, partialError)
                }
            }
        }
        
        urlSessionTask?.resume()
    }
}
