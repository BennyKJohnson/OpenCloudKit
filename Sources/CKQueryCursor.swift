//
//  CKQueryCursor.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 7/07/2016.
//
//

import Foundation

public class CKQueryCursor: NSObject {
    
    var data: NSData
    
    var zoneID: CKRecordZoneID
    
    init(data: NSData, zoneID: CKRecordZoneID) {
        
        self.data = data
        self.zoneID = zoneID
        
        super.init()
    }
}
