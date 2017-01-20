//
//  CKModifySubscriptionsURLRequest.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/1/17.
//
//

import Foundation

class CKModifySubscriptionsURLRequest: CKURLRequest {
    
    var subscriptionsToSave: [CKSubscription]?
    
    var subscriptionIDsToDelete: [String]?
    
    var zoneID: CKRecordZoneID?

    func operationsDictionary() -> [[String: Any]] {
        var operations: [[String: Any]] = []
        
        if let subscriptionsToSave = subscriptionsToSave {
            
            for subscription in subscriptionsToSave {
                
                let operation: [String: Any] = [
                    "operationType": "create".bridge(),
                    "subscription": subscription.subscriptionDictionary.bridge() as Any
                ]
                
                operations.append(operation)
            }
        }
        
        if let subscriptionIDsToDelete = subscriptionIDsToDelete {
            for subscriptionID in subscriptionIDsToDelete {
                
                let operation: [String: Any] = [
                    "operationType": "create".bridge(),
                    "subscription": (["subscriptionID": subscriptionID.bridge()] as [String: Any]).bridge() as Any
                ]
                
                operations.append(operation)
            }
        }
        
        return operations
    }
    
    init(subscriptionsToSave: [CKSubscription]?, subscriptionIDsToDelete: [String]?) {
        
        self.subscriptionsToSave = subscriptionsToSave
        self.subscriptionIDsToDelete = subscriptionIDsToDelete
        
        super.init()
        
        let properties: [String: Any] = ["operations": operationsDictionary().bridge() as Any]
        self.operationType = .subscriptions
        self.path = "modify"
        self.requestProperties = properties
        
        
    }
}
