//
//  CKModifyRecordZonesOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 15/07/2016.
//
//

import Foundation

public class CKModifyRecordZonesOperation : CKDatabaseOperation {
    
    
    public override init() {
        super.init()
    }
    
    public convenience init(recordZonesToSave: [CKRecordZone]?, recordZoneIDsToDelete: [CKRecordZoneID]?) {
        self.init()
        self.recordZonesToSave = recordZonesToSave
        self.recordZoneIDsToDelete = recordZoneIDsToDelete
    }
    
    
    public var recordZonesToSave: [CKRecordZone]?
    
    public var recordZoneIDsToDelete: [CKRecordZoneID]?
    
    var recordZoneErrors: [CKRecordZoneID: NSError] = [:]
    
    var recordZonesByZoneIDs:[CKRecordZoneID: CKRecordZone] = [:]
    
    /*  This block is called when the operation completes.
     The [NSOperation completionBlock] will also be called if both are set.
     If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
     a dictionary of recordZoneIDs to errors keyed off of CKPartialErrorsByItemIDKey.
     This call happens as soon as the server has
     seen all record changes, and may be invoked while the server is processing the side effects
     of those changes.
     */
    public var modifyRecordZonesCompletionBlock: (([CKRecordZone]?, [CKRecordZoneID]?, NSError?) -> Swift.Void)?
    
    func zoneOperations() -> [[String: AnyObject]] {
        
        var operationDictionaries: [[String: AnyObject]] = []
        if let recordZonesToSave = recordZonesToSave {
            let saveOperations = recordZonesToSave.map({ (zone) -> [String: AnyObject] in
                
                let operation: [String: AnyObject] = [
                    "operationType": "create".bridge(),
                    "zone": ["zoneID".bridge(): zone.zoneID.dictionary].bridge() as AnyObject
                ]
                
                return operation
            })
            
            operationDictionaries.append(contentsOf: saveOperations)
        }
        
        if let recordZoneIDsToDelete = recordZoneIDsToDelete {
            let deleteOperations = recordZoneIDsToDelete.map({ (zoneID) -> [String: AnyObject] in
                
                let operation: [String: AnyObject] = [
                    "operationType": "delete".bridge(),
                    "zone": ["zoneID".bridge(): zoneID.dictionary.bridge()].bridge() as AnyObject
                ]
                
                return operation
            })
            
            operationDictionaries.append(contentsOf: deleteOperations)
        }
        
        return operationDictionaries
    }
    
    override func performCKOperation() {
        
        let url = "\(databaseURL)/zones/modify"
        let zoneOperations = self.zoneOperations().bridge()
        
        let request: [String: AnyObject] = ["operations": zoneOperations]
        
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
                            self.recordZonesByZoneIDs[zone.zoneID] = zone
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
            self.modifyRecordZonesCompletionBlock?(Array(self.recordZonesByZoneIDs.values), self.recordZoneIDsToDelete, partialError)
            
            // Mark operation as complete
            self.finish(error: [])

  
    }
}
}
