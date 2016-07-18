//
//  CKModifyRecordsOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 8/07/2016.
//
//

import Foundation

public enum CKRecordSavePolicy : Int {
    case IfServerRecordUnchanged
    case ChangedKeys
    case AllKeys
}

let CKErrorRetryAfterKey = "CKRetryAfter"
let CKErrorRedirectURLKey = "CKRedirectURL"
let CKPartialErrorsByItemIDKey: String = "CKPartialErrors"

struct CKSubscriptionFetchErrorDictionary {
    
    static let subscriptionIDKey = "subscriptionID"
    
    static let reasonKey = "reason"
    
    static let serverErrorCodeKey = "serverErrorCode"
    
    static let redirectURLKey = "redirectURL"
    
    let subscriptionID: String
    
    let reason: String
    
    let serverErrorCode: String
    
    let redirectURL: String?
    
    init?(dictionary: [String: AnyObject]) {
        guard let subscriptionID = dictionary[CKSubscriptionFetchErrorDictionary.subscriptionIDKey] as? String,
        reason = dictionary[CKSubscriptionFetchErrorDictionary.reasonKey] as? String,
            serverErrorCode = dictionary[CKSubscriptionFetchErrorDictionary.serverErrorCodeKey] as? String else {
                return nil
        }
        
        self.subscriptionID = subscriptionID
        self.reason = reason
        self.serverErrorCode = serverErrorCode
        self.redirectURL = dictionary[CKSubscriptionFetchErrorDictionary.redirectURLKey] as? String
        
    }
}

struct CKRecordFetchErrorDictionary {
    
    static let recordNameKey = "recordName"
    static let reasonKey = "reason"
    static let serverErrorCodeKey = "serverErrorCode"
    static let retryAfterKey = "retryAfter"
    static let uuidKey = "uuid"
    static let redirectURLKey = "redirectURL"
    
    let recordName: String
    let reason: String
    let serverErrorCode: String
    let retryAfter: NSNumber?
    let uuid: String
    let redirectURL: String?
    
    init?(dictionary: [String: AnyObject]) {
        
        guard let recordName = dictionary[CKRecordFetchErrorDictionary.recordNameKey] as? String,
        reason = dictionary[CKRecordFetchErrorDictionary.reasonKey] as? String,
        serverErrorCode = dictionary[CKRecordFetchErrorDictionary.serverErrorCodeKey] as? String,
        uuid = dictionary[CKRecordFetchErrorDictionary.uuidKey] as? String else {
                return nil
        }
        
        self.recordName = recordName
        self.reason = reason
        self.serverErrorCode = serverErrorCode
        self.uuid = uuid
        
        self.retryAfter = (dictionary[CKRecordFetchErrorDictionary.retryAfterKey] as? NSNumber)
        self.redirectURL = dictionary[CKRecordFetchErrorDictionary.redirectURLKey] as? String
        
    }
}

public class CKModifyRecordsOperation: CKDatabaseOperation {

    public override init() {
        super.init()
    }
    
    public convenience init(recordsToSave records: [CKRecord]?, recordIDsToDelete recordIDs: [CKRecordID]?) {
        self.init()

        recordsToSave = records
        recordIDsToDelete = recordIDs
    }
    
    public var savePolicy: CKRecordSavePolicy = .IfServerRecordUnchanged
    
    public var recordsToSave: [CKRecord]?
    
    public var recordIDsToDelete: [CKRecordID]?
    
    var recordsByRecordIDs: [CKRecordID: CKRecord] = [:]
    
    /* Determines whether the batch should fail atomically or not. YES by default.
     This only applies to zones that support CKRecordZoneCapabilityAtomic. */
    public var isAtomic: Bool = false
    
    /* Called repeatedly during transfer.
     It is possible for progress to regress when a retry is automatically triggered.
     */
    public var perRecordProgressBlock: ((CKRecord, Double) -> Swift.Void)?
    
    /* Called on success or failure for each record. */
    public var perRecordCompletionBlock: ((CKRecord?, NSError?) -> Swift.Void)?
    
    
    /*  This block is called when the operation completes.
     The [NSOperation completionBlock] will also be called if both are set.
     If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
     a dictionary of recordIDs to errors keyed off of CKPartialErrorsByItemIDKey.
     This call happens as soon as the server has
     seen all record changes, and may be invoked while the server is processing the side effects
     of those changes.
     */
    public var modifyRecordsCompletionBlock: (([CKRecord]?, [CKRecordID]?, NSError?) -> Swift.Void)?

    func operationsDictionary() -> [[String: AnyObject]] {
        var operationsDictionaryArray: [[String: AnyObject]] = []
        
        if let recordIDsToDelete = recordIDsToDelete {
           let deleteOperations = recordIDsToDelete.map({ (recordID) -> [String: AnyObject] in
                let operationDictionary: [String: AnyObject] = [
                    "operationType": "delete",
                    "record":["recordName":recordID.recordName]
                ]
                
                return operationDictionary
            })
            
            operationsDictionaryArray.append(contentsOf: deleteOperations)
        }
        if let recordsToSave = recordsToSave {
            let saveOperations = recordsToSave.map({ (record) -> [String: AnyObject] in
             
                let operationType: String
                let fieldsDictionary: [String: AnyObject]
                
                var recordDictionary: [String: AnyObject] = ["recordType": record.recordType, "recordName": record.recordID.recordName]
                if let recordChangeTag = record.recordChangeTag {
                    
                    if savePolicy == .IfServerRecordUnchanged {
                        operationType = "update"
                    } else {
                        operationType = "forceUpdate"
                    }
                    
                    // Set Operation Type to Replace
                    if savePolicy == .AllKeys {
                        fieldsDictionary = record.fieldsDictionary(forKeys: record.allKeys())
                    } else {
                        fieldsDictionary = record.fieldsDictionary(forKeys: record.changedKeys())
                    }
                  
                    recordDictionary["recordChangeTag"] = recordChangeTag
                    
                } else {
                    // Create new record
                    fieldsDictionary = record.fieldsDictionary(forKeys: record.allKeys())
                    operationType = "create"
                }
                
                recordDictionary["fields"] = fieldsDictionary
                
                let operationDictionary: [String: AnyObject] = ["operationType": operationType, "record": recordDictionary]
                return operationDictionary
            })
            
            operationsDictionaryArray.append(contentsOf: saveOperations)
        }
    
        return operationsDictionaryArray
    }
    
    
    
    override func performCKOperation() {

        // Generate the CKOperation Web Service URL
        let url = "\(operationURL)/records/\(CKRecordOperation.modify)"
        
        var request: [String: AnyObject] = [:]
      
        if database?.scope == .public {
            request["atomic"] = false
        } else {
            request["atomic"] = isAtomic
        }
        
        request["operations"] = operationsDictionary()
        
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url, parameters: request) { (dictionary, error) in
            
            // Check if cancelled
            if self.isCancelled {
                // Send Cancelled Error to CompletionBlock
                let cancelError = NSError(domain: CKErrorDomain, code: CKErrorCode.OperationCancelled.rawValue, userInfo: nil)
                self.modifyRecordsCompletionBlock?(nil, nil, cancelError)
            }
            
            if let error = error {
                self.modifyRecordsCompletionBlock?(nil, nil, error)
                
            } else if let dictionary = dictionary {
                // Process Records
                if let recordsDictionary = dictionary["records"] as? [[String: AnyObject]] {
                    // Parse JSON into CKRecords
                    for recordDictionary in recordsDictionary {
                        
                        
                        if let record = CKRecord(recordDictionary: recordDictionary) {
                            // Append Record
                            self.recordsByRecordIDs[record.recordID] = record
                            
                            // Call RecordCallback
                            self.perRecordCompletionBlock?(record, nil)
                            
                        } else if let recordFetchError = CKRecordFetchErrorDictionary(dictionary: recordDictionary) {
                            
                            // Create Error
                            let error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: recordFetchError.reason])
                            self.perRecordCompletionBlock?(nil, error)
                        } else {
                            fatalError("Couldn't resolve record or record fetch error dictionary")
                        }
                    }
                }
            }
            
            // Call the final completionBlock
            let recordIDs = Array(self.recordsByRecordIDs.keys)
            let records = Array(self.recordsByRecordIDs.values)
            self.modifyRecordsCompletionBlock?(records, recordIDs, nil)
                
            // Mark operation as complete
            self.isExecuting = false
            self.isFinished = true
            
        }
    }
    

}
