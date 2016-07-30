//
//  CKQueryURLRequest.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 26/07/2016.
//
//

import Foundation

class CKQueryURLRequest: CKURLRequest {
    
    var cursor: Data?
    
    var limit: Int
    
    let query: CKQuery
    
    var queryResponses: [[String: AnyObject]] = []
    
    var requestedFields: [String]?
    
    var resultsCursor: Data?
    
    var zoneID: CKRecordZoneID?
    
    init(query: CKQuery, cursor: Data?, limit: Int, requestedFields: [String]?, zoneID: CKRecordZoneID?) {
        
        self.query = query
        self.cursor = cursor
        self.limit = limit
        self.requestedFields = requestedFields
        self.zoneID = zoneID
        
        super.init()
        
        self.path = "query"
        self.operationType = CKOperationRequestType.records
        
        // Setup Body Properties
        var parameters: [String: AnyObject] = [:]
        
        let isZoneWide = false
        if  let zoneID = zoneID where zoneID.zoneName != CKRecordZoneDefaultName {
            // Add ZoneID Dictionary to parameters
            
        }
        
        parameters["zoneWide"] = NSNumber(value: isZoneWide)
        parameters["query"] = query.dictionary.bridge()
        
        if let cursor = cursor {
            
            parameters["continuationMarker"] = cursor.base64Encoded.bridge()
        }
        accountInfoProvider = CloudKit.shared.defaultAccount
        requestProperties = parameters

    }
}
