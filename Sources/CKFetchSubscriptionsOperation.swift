//
//  CKFetchSubscriptionsOperation.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 13/07/2016.
//
//

import Foundation

public class CKFetchSubscriptionsOperation : CKDatabaseOperation {
    
    public var subscriptionErrors : [String : NSError] = [:]
    
    public var subscriptionsIDToSubscriptions: [String: CKSubscription] = [:]
    
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
    public var fetchSubscriptionCompletionBlock: (([String : CKSubscription]?, Error?) -> Void)?
    
    override func finishOnCallbackQueue(error: Error?) {
        var error = error
        if(error == nil){
            if (subscriptionErrors.count > 0) {
                error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo:
                    [NSLocalizedDescriptionKey: "Partial Error",
                     CKPartialErrorsByItemIDKey: subscriptionErrors])
            }
        }
        self.fetchSubscriptionCompletionBlock?(subscriptionsIDToSubscriptions, error)
        
        super.finishOnCallbackQueue(error: error)
    }

    
    override func performCKOperation() {
        
        let url = "\(operationURL)/subscriptions/lookup"
        
        var request: [String: Any] = [:]
        if let subscriptionIDs = subscriptionIDs {
            
            request["subscriptions"] = subscriptionIDs.bridge()
        }
        
        
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url, parameters: request) { (dictionary, networkError) in
            if(self.isCancelled){
                return
            }
            else if let error = networkError {
                
                self.finish(error: error)
                
            } else if let dictionary = dictionary {
                
                if let subscriptionsDictionary = dictionary["subscriptions"] as? [[String: Any]] {
                    // Parse JSON into CKRecords
                    for subscriptionDictionary in subscriptionsDictionary {
                        
                        if let subscription = CKSubscription(dictionary: subscriptionDictionary) {
                            // Append Record
                            self.subscriptionsIDToSubscriptions[subscription.subscriptionID] = subscription
                            
                        }  else if let subscriptionFetchError = CKSubscriptionFetchErrorDictionary(dictionary: subscriptionDictionary) {
                           
                            let errorCode = CKErrorCode.errorCode(serverError: subscriptionFetchError.serverErrorCode)!
                            let error = NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: [NSLocalizedDescriptionKey: subscriptionFetchError.reason])
                            
                            self.subscriptionErrors[subscriptionFetchError.subscriptionID] = error
                            
                        } else {
                            fatalError("Couldn't resolve record or record fetch error dictionary")
                        }
                    }
                    self.finish(error: nil)
                }
            }
        }
        
        urlSessionTask?.resume()
    }
}
