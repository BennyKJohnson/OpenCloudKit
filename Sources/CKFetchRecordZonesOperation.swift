//
//  CKFetchRecordZonesOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 15/07/2016.
//
//

import Foundation

public class CKFetchRecordZonesOperation : CKDatabaseOperation {
    
    
    public class func fetchAllRecordZonesOperation() -> Self {
        return self.init()
    }
    
    public override required init() {
        self.recordZoneIDs = nil
        super.init()

    }
    
    public init(recordZoneIDs zoneIDs: [CKRecordZoneID]) {
        self.recordZoneIDs = zoneIDs
        super.init()
    }
    
    var isFetchAllRecordZonesOperation: Bool = false
    
    var recordZoneIDs : [CKRecordZoneID]?
    
    var recordZoneErrors: [CKRecordZoneID: NSError] = [:]
    
    public var recordZoneByZoneID: [CKRecordZoneID: CKRecordZone] = [:]
    
    /*  This block is called when the operation completes.
     The [NSOperation completionBlock] will also be called if both are set.
     If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
     a dictionary of zoneIDs to errors keyed off of CKPartialErrorsByItemIDKey.
     */
    public var fetchRecordZonesCompletionBlock: (([CKRecordZoneID : CKRecordZone]?, NSError?) -> Swift.Void)?
    
    override func finishOnCallbackQueueWithError(error: NSError) {
        
        self.fetchRecordZonesCompletionBlock?(nil, error)
        
        // Mark operation as complete
        finish(error: [])
    }
    
    override func performCKOperation() {
        let url: String
        let request: [String: AnyObject]?
        
        if let recordZoneIDs = recordZoneIDs {
            
            url = "\(databaseURL)/zones/lookup"
            let zones =  recordZoneIDs.map({ (zoneID) -> [String: AnyObject] in
                return zoneID.dictionary
            })
            
            request = ["zones": zones.bridge()]
        } else {
            url = "\(databaseURL)/zones/list"
            request = nil
        }
        
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url, parameters: request) { (dictionary, error) in
            
            if self.isCancelled {
                // Send Cancelled Error to CompletionBlock
                let cancelError = NSError(domain: CKErrorDomain, code: CKErrorCode.OperationCancelled.rawValue, userInfo: nil)
                self.finishOnCallbackQueueWithError(error: cancelError)
            }
            
            if let error = error {
                self.finishOnCallbackQueueWithError(error: error)
                return
            } else if let dictionary = dictionary {
                // Process Records
                if let zoneDictionaries = dictionary["zones"] as? [[String: AnyObject]] {
                    // Parse JSON into CKRecords
                    for zoneDictionary in zoneDictionaries {
                        
                        if let zone = CKRecordZone(dictionary: zoneDictionary) {
                            self.recordZoneByZoneID[zone.zoneID] = zone
                        } else if let fetchError = CKFetchErrorDictionary<CKRecordZoneID>(dictionary: zoneDictionary) {
        
                            // Append Error
                            self.recordZoneErrors[fetchError.identifier] = fetchError.error()
                        }
                    }
                }
            }
            
            let partialError: NSError?
            if self.recordZoneErrors.count > 0 {
                partialError = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [CKPartialErrorsByItemIDKey: self.recordZoneErrors])
            } else {
                partialError = nil
            }
            
            // Call the final completionBlock
            self.fetchRecordZonesCompletionBlock?(self.recordZoneByZoneID, partialError)
            
            // Mark operation as complete
            self.finish(error: [])
            
        }
    }
    
}
