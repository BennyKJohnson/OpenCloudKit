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
    
    var isFinishing: Bool = false
    
    public var zoneID: CKRecordZoneID?

    public var resultsLimit: Int = CKQueryOperationMaximumResults

    public var desiredKeys: [String]?

    public var recordFetchedBlock: ((CKRecord) -> Swift.Void)?

    public var queryCompletionBlock: ((CKQueryCursor?, NSError?) -> Swift.Void)?
    
    override func performCKOperation() {
        
       
        let queryOperationURLRequest = CKQueryURLRequest(query: query!, cursor: cursor?.data.bridge(), limit: resultsLimit, requestedFields: desiredKeys, zoneID: zoneID)
        queryOperationURLRequest.accountInfoProvider = CloudKit.shared.defaultAccount
        queryOperationURLRequest.databaseScope = database?.scope ?? .public

        queryOperationURLRequest.completionBlock = { (result) in
            
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
                        self.cursor = CKQueryCursor(data: data, zoneID: CKRecordZoneID(zoneName: "_defaultZone", ownerName: ""))
                    }
                }
                
                
                // Process Records
                if let recordsDictionary = dictionary["records"] as? [[String: AnyObject]] {
                    // Parse JSON into CKRecords
                    for recordDictionary in recordsDictionary {
                        
                        if let record = CKRecord(recordDictionary: recordDictionary) {
                            // Call RecordCallback
                            self.recordFetchedBlock?(record)
                        } else {
                            // Create Error
                            let error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: "Failed to parse record from server"])
                            self.queryCompletionBlock?(nil, error)
                        }
                    }
                }
                
                self.queryCompletionBlock?(self.cursor, nil)
                
            case .error(let error):
                self.queryCompletionBlock?(nil, error.error)
            }
        }
        
        queryOperationURLRequest.performRequest()
    }
}



