//
//  CKDatabase.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation

public enum CKDatabaseScope: Int, CustomStringConvertible {
    case Public = 1
    case Private
    case Shared
    
    public var description: String {
        switch(self) {
        case .Private:
            return "private"
        case .Public:
            return "public"
        case .Shared:
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
    
    public func addOperation(_ operation: CKDatabaseOperation) {
        operation.database = self
        // Add to queue
        operationQueue.addOperation(operation)
        
    }
    
    public func perform(query: CKQuery, inZoneWithID zoneID: CKRecordZoneID?,completionHandler: ([CKRecord]?,
        NSError?) -> Void) {
        
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
        
        queryOperation.start()
    }
    
    public func fetch(withRecordID recordID: CKRecordID, completionHandler: (CKRecord?,
        NSError?) -> Void) {
        
     let fetchRecordOperation = CKFetchRecordsOperation(recordIDs: [recordID])
        fetchRecordOperation.database = self
        fetchRecordOperation.fetchRecordsCompletionBlock = {
            (recordIDsForRecords, error) in
            
           completionHandler(recordIDsForRecords?[recordID], error)
        }
        
        fetchRecordOperation.start()
    }
    
    public func save(record: CKRecord, completionHandler: (CKRecord?,
        NSError?) -> Void) {
    
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = {
            (records, recordIDs, error) in
            
            completionHandler(records?.first, error)
        }

        operation.start()
    }


    public func delete(withRecordID recordID: CKRecordID, completionHandler: (CKRecordID?,
        NSError?) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: [], recordIDsToDelete: [recordID])
        operation.modifyRecordsCompletionBlock = {
            (records, recordIDs, error) in
            
            completionHandler(recordIDs?.first, error)
        }
        
        operation.start()
        
    }
    
    /* CKFetchSubscriptionsOperation and CKModifySubscriptionsOperation are the more configurable,
     CKOperation-based alternative to these methods */
    public func fetch(withSubscriptionID subscriptionID: String, completionHandler: (CKSubscription?, NSError?) -> Swift.Void) {
        
        
        
        
    }
    
    public func fetchAll(completionHandler: ([CKSubscription]?, NSError?) -> Swift.Void) {
        
    }
    
    public func save(_ subscription: CKSubscription, completionHandler: (CKSubscription?, NSError?) -> Swift.Void) {
        let modifyOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
        modifyOperation.modifySubscriptionsCompletionBlock = {
            (subscriptions, deleted, error) in
            
            completionHandler(subscriptions?.first, error)
        }
        
        modifyOperation.start()
    }
    
    public func delete(withSubscriptionID subscriptionID: String, completionHandler: (String?, NSError?) -> Swift.Void) {
        let modifyOperation = CKModifySubscriptionsOperation(subscriptionsToSave: nil, subscriptionIDsToDelete: [subscriptionID])
        modifyOperation.modifySubscriptionsCompletionBlock = {
            (subscriptions, deleted, error) in
            
            completionHandler(deleted?.first, error)
        }
        
        modifyOperation.start()
    }
 
}
