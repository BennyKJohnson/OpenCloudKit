//
//  CKFetchRecordsOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 7/07/2016.
//
//

import Foundation

public class CKFetchRecordsOperation: CKDatabaseOperation {
    
    var isFetchCurrentUserOperation = false
    
    var recordErrors: [String: AnyObject] = [:]
    
    var shouldFetchAssetContent: Bool = false
    
    var recordIDsToRecords: [CKRecordID: CKRecord] = [:]
    
    public class func fetchCurrentUserRecord() -> Self {
        let operation = self.init()
        operation.isFetchCurrentUserOperation = true
        
        return operation
    }
    
    public override required init() {
        super.init()
    }
    
    public var recordIDs: [CKRecordID]?
    
    public var desiredKeys: [String]?
    
    public convenience init(recordIDs: [CKRecordID]) {
        self.init()
        self.recordIDs = recordIDs
    }
    
    override func performCKOperation() {
        
        // Generate the CKOperation Web Service URL
        let url = "\(operationURL)/records/\(CKRecordOperation.lookup)"
        
        var request: [String: AnyObject] = [:]
        let lookupRecords = recordIDs?.map { (recordID) -> [String: AnyObject] in
            return ["recordName": recordID.recordName.bridge()]
        }
        
        request["records"] = lookupRecords
        
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url, parameters: request) { (dictionary, error) in
            
            // Check if cancelled
            if self.isCancelled {
                // Send Cancelled Error to CompletionBlock
                let cancelError = NSError(domain: CKErrorDomain, code: CKErrorCode.OperationCancelled.rawValue, userInfo: nil)
                self.fetchRecordsCompletionBlock?(nil, cancelError)
            }
            
            if let error = error {
                self.fetchRecordsCompletionBlock?(nil, error)
            } else if let dictionary = dictionary {
                // Process Records
                if let recordsDictionary = dictionary["records"] as? [[String: AnyObject]] {
                    // Parse JSON into CKRecords
                    for (index,recordDictionary) in recordsDictionary.enumerated() {
                        
                        // Call Progress Block, this is hacky support and not the callbacks intented purpose
                        let progress = Double(index + 1) / Double(self.recordIDs!.count)
                        self.perRecordProgressBlock?(self.recordIDs![index],progress)
                        
                        if let record = CKRecord(recordDictionary: recordDictionary) {
                            self.recordIDsToRecords[record.recordID] = record
                            
                            // Call RecordCallback
                            self.perRecordCompletionBlock?(record, record.recordID, nil)
                            
                        } else {
                            
                            // Create Error
                            let error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: "Failed to parse record from server"])
                            // Call RecordCallback
                            self.perRecordCompletionBlock?(nil, nil, error)
                            
                        }
                        
                        
                    }
                }
            }
            
            // Call the final completionBlock
            self.fetchRecordsCompletionBlock?(self.recordIDsToRecords, nil)
            
            // Mark operation as complete
            self.isExecuting = false
            self.isFinished = true
            
        }
    }
    
    /* Called repeatedly during transfer. */
    public var perRecordProgressBlock: ((CKRecordID, Double) -> Void)?
    
    /* Called on success or failure for each record. */
    public var perRecordCompletionBlock: ((CKRecord?, CKRecordID?, NSError?) -> Void)?
    
    
    /*  This block is called when the operation completes.
     The [NSOperation completionBlock] will also be called if both are set.
     If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
     a dictionary of recordIDs to errors keyed off of CKPartialErrorsByItemIDKey.
     */
    public var fetchRecordsCompletionBlock: (([CKRecordID : CKRecord]?, NSError?) -> Void)?
    
    
}
