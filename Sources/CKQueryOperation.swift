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
        
        var parameters: [String: AnyObject] = [:]
        
        let isZoneWide = false
        if  let zoneID = zoneID where zoneID.zoneName != CKRecordZoneDefaultName {
            // Add ZoneID Dictionary to parameters
            
        }
        
        parameters["zoneWide"] = NSNumber(value: isZoneWide)
        parameters["query"] = query?.dictionary.bridge()
        
        if let cursor = cursor {
            
            parameters["continuationMarker"] = cursor.data.base64Encoded.bridge()
        }
        
        let url = "\(operationURL)/records/\(CKRecordOperation.query)"
        print(url)
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url, parameters: parameters) { (dictionary, error) in
            
            // Check if cancelled
            if self.isCancelled {
                // Send Cancelled Error to CompletionBlock
                let cancelError = NSError(domain: CKErrorDomain, code: CKErrorCode.OperationCancelled.rawValue, userInfo: nil)
                self.queryCompletionBlock?(nil, cancelError)
            }
            
            if let error = error {
                self.queryCompletionBlock?(nil, error)
            } else if let dictionary = dictionary {
                // Process cursor
                if let continuationMarker = dictionary["continuationMarker"] as? String {
                    
                    #if os(Linux)
                        let data = NSData(base64Encoded: continuationMarker, options: [])
                    #else
                        let data = NSData(base64Encoded: continuationMarker)!
                    #endif
                    
                    self.cursor = CKQueryCursor(data: data, zoneID: CKRecordZoneID(zoneName: "_defaultZone", ownerName: ""))
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
            }
            
            self.queryCompletionBlock?(self.cursor, nil)
    }
}


}
