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
    
    var recordErrors: [String: Any] = [:] // todo use this for partial errors
    
    var shouldFetchAssetContent: Bool = false
    
    var recordIDsToRecords: [CKRecordID: CKRecord] = [:]
    
    /* Called repeatedly during transfer. */
    public var perRecordProgressBlock: ((CKRecordID, Double) -> Void)?
    
    /* Called on success or failure for each record. */
    public var perRecordCompletionBlock: ((CKRecord?, CKRecordID?, Error?) -> Void)?
    
    
    /*  This block is called when the operation completes.
     The [NSOperation completionBlock] will also be called if both are set.
     If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
     a dictionary of recordIDs to errors keyed off of CKPartialErrorsByItemIDKey.
     */
    public var fetchRecordsCompletionBlock: (([CKRecordID : CKRecord]?, Error?) -> Void)?
    
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
    
    override func finishOnCallbackQueue(error: Error?) {
        if(error == nil){
            // todo build partial error using recordErrors
        }
        self.fetchRecordsCompletionBlock?(self.recordIDsToRecords, error)
        
        super.finishOnCallbackQueue(error: error)
    }
    
    func completed(record: CKRecord?, recordID: CKRecordID?, error: Error?){
        callbackQueue.async {
            self.perRecordCompletionBlock?(record, recordID, error)
        }
    }
    
    func progressed(recordID: CKRecordID, progress: Double){
        callbackQueue.async {
            self.perRecordProgressBlock?(recordID, progress)
        }
    }
    
    override func performCKOperation() {
        
        // Generate the CKOperation Web Service URL
        let url = "\(operationURL)/records/\(CKRecordOperation.lookup)"
        
        var request: [String: Any] = [:]
        let lookupRecords = recordIDs?.map { (recordID) -> [String: Any] in
            return ["recordName": recordID.recordName.bridge()]
        }
        
        request["records"] = lookupRecords?.bridge() 
        
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url, parameters: request) { [weak self] (dictionary, error) in
            
            guard let strongSelf = self, !strongSelf.isCancelled else {
                return
            }
            
            defer {
                strongSelf.finish(error: error)
            }
            
            guard let dictionary = dictionary,
                let recordsDictionary = dictionary["records"] as? [[String: Any]],
                error == nil else {
                    return
            }
            
            // Process Records
            // Parse JSON into CKRecords
            for (index,recordDictionary) in recordsDictionary.enumerated() {
                
                // Call Progress Block, this is hacky support and not the callbacks intented purpose
                let progress = Double(index + 1) / Double((strongSelf.recordIDs!.count))
                let recordID = strongSelf.recordIDs![index]
                strongSelf.progressed(recordID: recordID, progress: progress)
                
                if let record = CKRecord(recordDictionary: recordDictionary) {
                    strongSelf.recordIDsToRecords[record.recordID] = record
                    
                    // Call per record callback, not to be confused with finished
                    strongSelf.completed(record: record, recordID: record.recordID, error: nil)
                    
                } else {
                    
                    // Create Error
                    let error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: "Failed to parse record from server".bridge()])
                    
                    // Call per record callback, not to be confused with finished
                    strongSelf.completed(record: nil, recordID: nil, error: error)
                    
                    // todo add to recordErrors array
                    
                }
            }            
        }
    }
    
    
    
    
}
