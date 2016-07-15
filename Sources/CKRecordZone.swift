//
//  CKRecordZone.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 15/07/2016.
//
//

import Foundation

public struct CKRecordZoneCapabilities : OptionSet {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    
    /* This zone supports CKFetchRecordChangesOperation */
    public static var fetchChanges: CKRecordZoneCapabilities = CKRecordZoneCapabilities(rawValue: 1)
    
    /* Batched changes to this zone happen atomically */
    public static var atomic: CKRecordZoneCapabilities = CKRecordZoneCapabilities(rawValue: 2)
    
    /* Records in this zone can be shared */
    public static var sharing: CKRecordZoneCapabilities = CKRecordZoneCapabilities(rawValue: 4)
}

/* The default zone has no capabilities */
public let CKRecordZoneDefaultName: String = "_defaultZone"

public let CKRecordZoneIDDefaultOwnerName = "__defaultOwner__"

public class CKRecordZone : NSObject {
    
    
    public class func `default`() -> CKRecordZone {
        return CKRecordZone(zoneName: CKRecordZoneDefaultName)
    }
    
    public convenience init(zoneName: String) {
        let zoneID = CKRecordZoneID(zoneName: zoneName, ownerName: CKRecordZoneIDDefaultOwnerName)
        self.init(zoneID: zoneID)
    }
    
    public init(zoneID: CKRecordZoneID) {
        self.zoneID = zoneID
        super.init()
    }
    
    
    public let zoneID: CKRecordZoneID

    /* Capabilities are not set until a record zone is saved */
    public var capabilities: CKRecordZoneCapabilities = CKRecordZoneCapabilities(rawValue: 0)
}

extension CKRecordZone {
    convenience init?(dictionary: [String: AnyObject]) {
        
        guard let zoneIDDictionary = dictionary["zoneID"] as? [String: AnyObject], zoneID = CKRecordZoneID(dictionary: zoneIDDictionary) else {
            return nil
        }
        
        self.init(zoneID: zoneID)
        
        if let isAtomic = dictionary["atomic"] as? Bool where isAtomic {
            capabilities = CKRecordZoneCapabilities.atomic
        }
    }
    
    var dictionary: [String: AnyObject] {
        return ["zoneID": zoneID.dictionary]
    }
}
