//
//  CKQueryNotification.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/1/17.
//
//

import Foundation

public class CKQueryNotification : CKNotification {

    
    public override init(fromRemoteNotificationDictionary notificationDictionary: [AnyHashable : Any]) {
        
        super.init(fromRemoteNotificationDictionary: notificationDictionary)
        
        guard let cloudDictionary = notificationDictionary[CKNotificationCKKey] as? [String: Any] else {
            return
        }
        
        if let queryDictionary = cloudDictionary[CKNotificationQueryNotificationKey] as? [String: Any] {
            
            // Set recordID
            if
                let zoneName = queryDictionary["zid"] as? String,
                let ownerName = queryDictionary["zoid"] as? String,
                let recordName = queryDictionary["rid"] as? String
                {
                    let zoneID = CKRecordZoneID(zoneName: zoneName, ownerName: ownerName)
                    recordID = CKRecordID(recordName: recordName, zoneID: zoneID)
            }
            
            // Set database scope
            if let dbs = queryDictionary["dbs"] as? NSNumber, let scope = CKDatabaseScope(rawValue: dbs.intValue)  {
                databaseScope = scope
            }
            
            // Set notification reason
            if let fo = queryDictionary["fo"] as? NSNumber, let reason = CKQueryNotificationReason(rawValue: fo.intValue)  {
                queryNotificationReason = reason
            } else {
                queryNotificationReason = .recordCreated
            }
            
            // Set Subscription ID
            if let sid = queryDictionary["sid"] as? String {
                subscriptionID = sid
            }
        }
    }

    public var queryNotificationReason: CKQueryNotificationReason = .recordCreated
    
    /* A set of key->value pairs for creates and updates.  You request the server fill out this property via the
     "desiredKeys" property of CKNotificationInfo */
    public var recordFields: [String : Any]?
    
    public var recordID: CKRecordID?
    
    public var isPublicDatabase: Bool {
        return databaseScope == .public
    }
    
    public var databaseScope: CKDatabaseScope = .public
}
