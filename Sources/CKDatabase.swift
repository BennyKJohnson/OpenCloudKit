//
//  CKDatabase.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation

public enum CKDatabaseScope: Int, CustomStringConvertible {
    case `public` = 1
    case `private`
    case  shared
    
    public var description: String {
        switch(self) {
        case .private:
            return "private"
        case .public:
            return "public"
        case .shared:
            return "shared"
        }
    }
}

enum CKRecordOperation: String {
    case query
    case lookup
    case modify
    case changes
    case resolve
    case accept
}

enum CKModifyOperation: String {
    case create
    case update
    case forceUpdate
    case replace
    case forceReplace
    case delete
    case forceDelete
}

public class CKDatabase {
    
    weak var container: CKContainer!
    
    public let scope: CKDatabaseScope
    
    let operationQueue = OperationQueue()
    
    init(container: CKContainer, scope: CKDatabaseScope) {
        self.container = container
        self.scope = scope
    }
    
    public func add(_ operation: CKDatabaseOperation) {
        operation.database = self
        // Add to queue
        operationQueue.addOperation(operation)
        
    }
    
    func schedule(operation: CKDatabaseOperation) {
        
        operation.database = self
        operation.queuePriority = .veryHigh
        operation.qualityOfService = .default
        operationQueue.addOperation(operation)

    }
}

extension CKDatabase {
    
    /* Records convenience methods */
    public func fetch(withRecordID recordID: CKRecordID, completionHandler: @escaping (CKRecord?,
        Error?) -> Void) {
        
        let fetchRecordOperation = CKFetchRecordsOperation(recordIDs: [recordID])
        fetchRecordOperation.database = self
        fetchRecordOperation.fetchRecordsCompletionBlock = {
            (recordIDsForRecords, error) in
            
            completionHandler(recordIDsForRecords?[recordID], error)
        }
        
        schedule(operation: fetchRecordOperation)
        
    }
    
    public func save(record: CKRecord, completionHandler: @escaping (CKRecord?,
        Error?) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.database = self
        operation.modifyRecordsCompletionBlock = {
            (records, recordIDs, error) in
            
            completionHandler(records?.first, error)
        }
        
        schedule(operation: operation)
    }
    
    public func delete(withRecordID recordID: CKRecordID, completionHandler: @escaping (CKRecordID?,
        Error?) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: [], recordIDsToDelete: [recordID])
        operation.modifyRecordsCompletionBlock = {
            (records, recordIDs, error) in
            
            completionHandler(recordIDs?.first, error)
        }
        
        schedule(operation: operation)
        
    }
    
    public func perform(query: CKQuery, inZoneWithID zoneID: CKRecordZoneID?,completionHandler: @escaping ([CKRecord]?,
        Error?) -> Void) {
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.database = self

        queryOperation.zoneID = zoneID
        
        var records: [CKRecord] = []
        queryOperation.recordFetchedBlock = {
            (record) in
            records.append(record)
        }
        
        queryOperation.queryCompletionBlock = {
            (cursor, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                completionHandler(records, nil)
            }
        }
        
        schedule(operation: queryOperation)
    }
    
    /* Zones convenience methods */

    public func fetchAll(completionHandler: @escaping ([CKRecordZone]?, Error?) -> Swift.Void) {
        let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        operation.fetchRecordZonesCompletionBlock = {
            (recordZoneByZoneID, error) in
            if let recordZones = recordZoneByZoneID?.values {
                completionHandler(Array(recordZones), error)
            } else {
                completionHandler(nil, error)
            }
        }
        
        schedule(operation: operation)
    }
    
    public func fetch(withRecordZoneID zoneID: CKRecordZoneID, completionHandler: @escaping (CKRecordZone?, Error?) -> Swift.Void) {
        let operation = CKFetchRecordZonesOperation(recordZoneIDs: [zoneID])
        operation.fetchRecordZonesCompletionBlock = {
            (recordZoneByZoneID, error) in
            
            completionHandler(recordZoneByZoneID?[zoneID], error)

        }
        
        schedule(operation: operation)
    }
    
    public func save(_ zone: CKRecordZone, completionHandler: @escaping (CKRecordZone?, Error?) -> Swift.Void) {
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
        operation.modifyRecordZonesCompletionBlock = {
            (savedZones, deletedZones, error) in
            
            completionHandler(savedZones?.first, error)
        }
        
        schedule(operation: operation)
    }
    
    public func delete(withRecordZoneID zoneID: CKRecordZoneID, completionHandler: @escaping (CKRecordZoneID?, Error?) -> Swift.Void) {
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [], recordZoneIDsToDelete: [zoneID])
        operation.modifyRecordZonesCompletionBlock = {
            (savedZones, deletedZones, error) in
            
            completionHandler(deletedZones?.first, error)
        }
    
        schedule(operation: operation)
    }

    /* Subscriptions convenience methods */
    
    public func fetchAll(completionHandler: @escaping ([CKSubscription]?, Error?) -> Swift.Void) {
        let operation = CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
        operation.fetchSubscriptionCompletionBlock = {
            (subscriptionsBySubscriptionID, error) in
            
            if let subscriptions = subscriptionsBySubscriptionID?.values {
                completionHandler(Array(subscriptions), error)
            } else {
                completionHandler(nil, error)
            }
        }
        
        schedule(operation: operation)
    }
    
    public func fetch(withSubscriptionID subscriptionID: String, completionHandler: @escaping (CKSubscription?, Error?) -> Swift.Void) {
        let operation = CKFetchSubscriptionsOperation(subscriptionIDs: [subscriptionID])
        operation.fetchSubscriptionCompletionBlock = {
            (subscriptionsBySubscriptionID, error) in
            
            completionHandler(subscriptionsBySubscriptionID?[subscriptionID], error)
          
        }
        
        schedule(operation: operation)
    }
    
    public func save(_ subscription: CKSubscription, completionHandler: @escaping (CKSubscription?, Error?) -> Swift.Void) {
        let modifyOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
        modifyOperation.modifySubscriptionsCompletionBlock = {
            (subscriptions, deleted, error) in
            
            completionHandler(subscriptions?.first, error)
        }
        
        schedule(operation: modifyOperation)
    }
    
    public func delete(withSubscriptionID subscriptionID: String, completionHandler: @escaping (String?, Error?) -> Swift.Void) {
        let modifyOperation = CKModifySubscriptionsOperation(subscriptionsToSave: nil, subscriptionIDsToDelete: [subscriptionID])
        modifyOperation.modifySubscriptionsCompletionBlock = {
            (subscriptions, deleted, error) in
            
            completionHandler(deleted?.first, error)
        }
        
        schedule(operation: modifyOperation)
    }
 
}
