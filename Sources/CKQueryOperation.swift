//
//  CKQueryOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 7/07/2016.
//
//

import Foundation

let CKQueryOperationMaximumResults = 0

public class CKQueryOperation: CKDatabaseOperation {
    
    public override init() {
        super.init()
    }
    
    public convenience init(query: CKQuery) {
        self.init()
        self.query = query

    }
    
    public convenience init(cursor: CKQueryCursor) {
        self.init()
        self.cursor = cursor
    }
    
    public var shouldFetchAssetContent = true
    
    public var query: CKQuery?
    
    public var cursor: CKQueryCursor?
    
    public var resultsCursor: CKQueryCursor?
    
    var isFinishing: Bool = false
    
    public var zoneID: CKRecordZoneID?

    public var resultsLimit: Int = CKQueryOperationMaximumResults

    public var desiredKeys: [String]?

    public var recordFetchedBlock: ((CKRecord) -> Swift.Void)?

    public var queryCompletionBlock: ((CKQueryCursor?, NSError?) -> Swift.Void)?
    
    override func CKOperationShouldRun() throws {
        // "Warn: There's no point in running a query if there are no progress or completion blocks set. Bailing early."
        
        if(query == nil && cursor == nil){
            throw CKPrettyError(code: CKErrorCode.InvalidArguments, description: "either a query or query cursor must be provided for \(self)")
        }
    }
    
    override func finishOnCallbackQueue(error: Error?) {
        // log "Operation %@ has completed. Query cursor is %@.%@%@"
        self.queryCompletionBlock?(self.resultsCursor, error as NSError?)
        
        super.finishOnCallbackQueue(error: error)
    }
    
    func fetched(record: CKRecord){
        callbackQueue.async {
            self.recordFetchedBlock?(record)
        }
    }
    
    override func performCKOperation() {
        
        let queryOperationURLRequest = CKQueryURLRequest(query: query!, cursor: cursor?.data.bridge(), limit: resultsLimit, requestedFields: desiredKeys, zoneID: zoneID)
        queryOperationURLRequest.accountInfoProvider = CloudKit.shared.defaultAccount
        queryOperationURLRequest.databaseScope = database?.scope ?? .public
        
        queryOperationURLRequest.completionBlock = { [weak self] (result) in
            guard let strongSelf = self, !strongSelf.isCancelled else {
                return
            }
            switch result {
            case .success(let dictionary):
                
                // Process cursor
                if let continuationMarker = dictionary["continuationMarker"] as? String {
                    
                    #if os(Linux)
                        let data = NSData(base64Encoded: continuationMarker, options: [])
                    #else
                        let data = NSData(base64Encoded: continuationMarker)
                    #endif
                    
                    if let data = data {
                        strongSelf.resultsCursor = CKQueryCursor(data: data, zoneID: CKRecordZoneID(zoneName: "_defaultZone", ownerName: ""))
                    }
                }
                
                
                // Process Records
                if let recordsDictionary = dictionary["records"] as? [[String: Any]] {
                    // Parse JSON into CKRecords
                    for recordDictionary in recordsDictionary {
                        
                        if let record = CKRecord(recordDictionary: recordDictionary) {
                            // Call RecordCallback
                            strongSelf.fetched(record: record)
                        } else {
                            // Create Error
                            // Invalid state to be in, this operation normally doesnt provide partial errors
                            let error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: "Failed to parse record from server"])
                            strongSelf.finish(error: error)
                            return
                        }
                    }
                }
                strongSelf.finish(error: nil)
            case .error(let error):
                strongSelf.finish(error: error.error)
            }
        }
        
        queryOperationURLRequest.performRequest()
    }
}



