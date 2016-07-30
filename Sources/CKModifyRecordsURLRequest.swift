//
//  CKModifyRecordsURLRequest.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 27/07/2016.
//
//

import Foundation

class CKModifyRecordsURLRequest: CKURLRequest {
    
    var recordsToSave: [CKRecord]?
    
    var recordIDsToDelete: [CKRecordID]?
    
    var recordsByRecordIDs: [CKRecordID: CKRecord] = [:]
    
    var atomic: Bool = true
    
    var sendAllFields: Bool
    
    init(recordsToSave: [CKRecord], recordIDsToDelete: [CKRecordID], sendAllFields: Bool) {
        
        self.recordsToSave = recordsToSave
        self.recordIDsToDelete = recordIDsToDelete
        self.sendAllFields = sendAllFields
        
    }
    
    
    
    
    
    
}
