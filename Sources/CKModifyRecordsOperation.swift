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
    
    init?(dictionary: [String: Any]) {
        guard
        let subscriptionID = dictionary[CKSubscriptionFetchErrorDictionary.subscriptionIDKey] as? String,
        let reason = dictionary[CKSubscriptionFetchErrorDictionary.reasonKey] as? String,
        let serverErrorCode = dictionary[CKSubscriptionFetchErrorDictionary.serverErrorCodeKey] as? String else {
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
    
    let recordName: String?
    let reason: String
    let serverErrorCode: String
    let retryAfter: NSNumber?
    let uuid: String?
    let redirectURL: String?
    
    init?(dictionary: [String: Any]) {
        
        guard  let reason = dictionary[CKRecordFetchErrorDictionary.reasonKey] as? String,
        let serverErrorCode = dictionary[CKRecordFetchErrorDictionary.serverErrorCodeKey] as? String  else {
                return nil
        }
        
        self.recordName = dictionary[CKRecordFetchErrorDictionary.recordNameKey] as? String
        self.reason = reason
        self.serverErrorCode = serverErrorCode
        
        self.uuid = dictionary[CKRecordFetchErrorDictionary.uuidKey] as? String
        
        
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
    
    //var recordsByRecordIDs: [CKRecordID: CKRecord] = [:] // not sure what this is for yet
    
    /* Determines whether the batch should fail atomically or not. YES by default.
     This only applies to zones that support CKRecordZoneCapabilityAtomic. */
    public var isAtomic: Bool = false
    
    public var zoneID: CKRecordZoneID?
    
    /* Called repeatedly during transfer.
     It is possible for progress to regress when a retry is automatically triggered.
     Todo: still to be implemented
     */
    public var perRecordProgressBlock: ((CKRecord, Double) -> Swift.Void)?
    
    /* Called on success or failure for each record. */
    public var perRecordCompletionBlock: ((CKRecord?, Error?) -> Swift.Void)?
    
    private var recordErrors: [CKRecordID: Error] = [:]
    
    private var savedRecords: [CKRecord]?
    
    private var deletedRecordIDs: [CKRecordID]?
    
    /*  This block is called when the operation completes.
     The [NSOperation completionBlock] will also be called if both are set.
     If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
     a dictionary of recordIDs to errors keyed off of CKPartialErrorsByItemIDKey.
     This call happens as soon as the server has
     seen all record changes, and may be invoked while the server is processing the side effects
     of those changes.
     */
    public var modifyRecordsCompletionBlock: (([CKRecord]?, [CKRecordID]?, Error?) -> Swift.Void)?

    override func finishOnCallbackQueue(error: Error?) {
        var error = error
        if(error == nil){
            // report any partial errors

            if(recordErrors.count > 0){
                error = CKPrettyError(code: CKErrorCode.PartialFailure, userInfo: [NSLocalizedDescriptionKey: "Partial Failure", CKPartialErrorsByItemIDKey: recordErrors], format: "Failed to modify some records")
            }
        }
        
        // Call the final completionBlock
        self.modifyRecordsCompletionBlock?(savedRecords, deletedRecordIDs, error)
        
        self.modifyRecordsCompletionBlock = nil
        self.perRecordProgressBlock = nil
        self.perRecordCompletionBlock = nil
        
        super.finishOnCallbackQueue(error: error)
    }
    
    func completed(record: CKRecord?, error: Error?){
        callbackQueue.async {
            self.perRecordCompletionBlock?(record, error)
        }
    }
    
    func progressed(record: CKRecord, progress: Double){
        callbackQueue.async {
            self.perRecordProgressBlock?(record, progress)
        }
    }
    
    override func CKOperationShouldRun() throws {
        
        // todo validate recordsToSave
        
        // "An added share is being saved without its rootRecord (%@)"
        
        // "You can't save and delete the same record (%@) in a single operation"
        
        // "You can't delete the same record (%@) twice in a single operation"
        
        // "Unexpected recordID in property recordIDsToDelete passed to %@: %@"
        
    }
    
    override func performCKOperation() {

        // Generate the CKOperation Web Service URL
        let request = CKModifyRecordsURLRequest(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete, isAtomic: isAtomic, database: database!, savePolicy: savePolicy, zoneID: zoneID)
        request.accountInfoProvider = CloudKit.shared.defaultAccount
        
        request.completionBlock = { (result) in
            if(self.isCancelled){
                return
            }
            
            switch result {
            case .error(let error):
                self.modifyRecordsCompletionBlock?(nil, nil, error.error)
            case .success(let dictionary):
                
                // Process Records
                if let recordsDictionary = dictionary["records"] as? [[String: Any]] {
                    
                    self.savedRecords = [CKRecord]()
                    self.deletedRecordIDs = [CKRecordID]()
                    // Parse JSON into CKRecords
                    for recordDictionary in recordsDictionary {
                        
                        if let record = CKRecord(recordDictionary: recordDictionary) {
                            // Append Record
                            //self.recordsByRecordIDs[record.recordID] = record
                            self.savedRecords?.append(record)
                            
                            // Call RecordCallback
                            self.completed(record: record, error: nil)
                            
                        } else if let recordFetchError = CKRecordFetchErrorDictionary(dictionary: recordDictionary) {
                            
                            // Create Error
                            let error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: recordFetchError.reason])
                            let recordName = recordDictionary["recordName"] as! String
                            let recordID = CKRecordID(recordName: recordName) // todo: get zone from dictionary
                            
                            self.recordErrors[recordID] = error
                            
                            // todo the original record should be passed in here, that is probably what the self.recordsByRecordIDs was for
                            self.completed(record: nil, error: error)
                        } else {
                            
                            if let _ = recordDictionary["recordName"],
                                let _ = recordDictionary["deleted"] {
                                
                                let recordName = recordDictionary["recordName"] as! String
                                let recordID = CKRecordID(recordName: recordName) // todo: get zone from dictionary
                                self.deletedRecordIDs?.append(recordID)
                                
                                
                            } else {
                                fatalError("Couldn't resolve record or record fetch error dictionary")
                            }
                        }
                    }
                }
            }
            
            // Mark operation as complete
            self.finish(error: nil)
            
        }
        
        request.performRequest()

        
        
        /*
        
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
                if let recordsDictionary = dictionary["records"] as? [[String: Any]] {
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
                            
                            if let _ = recordDictionary["recordName"],
                            let _ = recordDictionary["deleted"] {
                                
                            } else {
                                fatalError("Couldn't resolve record or record fetch error dictionary")
                            }
                        }
                    }
                }
            }
            
            // Call the final completionBlock
            let recordIDs = Array(self.recordsByRecordIDs.keys)
            let records = Array(self.recordsByRecordIDs.values)
            self.modifyRecordsCompletionBlock?(records, recordIDs, nil)
                
            // Mark operation as complete
            self.finish(error: [])
            
        }
 
    }
    */

    }
}
