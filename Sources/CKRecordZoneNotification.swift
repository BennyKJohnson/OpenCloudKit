//
//  CKRecordZoneNotification.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/1/17.
//
//

import Foundation

public class CKRecordZoneNotification : CKNotification {
    
    public var recordZoneID: CKRecordZoneID?

    public var databaseScope: CKDatabaseScope = .public
    
    override init(fromRemoteNotificationDictionary notificationDictionary: [AnyHashable : Any]) {
        super.init(fromRemoteNotificationDictionary: notificationDictionary)
        
        notificationType = CKNotificationType.recordZone
        
        if let cloudDictionary = notificationDictionary["ck"] as? [String: Any] {
            
            if let zoneDictionary = cloudDictionary["fet"] as? [String: Any] {
                
                // Set RecordZoneID
                if let zoneName = zoneDictionary["zid"] as? String {
                    let zoneID = CKRecordZoneID(zoneName: zoneName, ownerName: "__defaultOwner__")
                    recordZoneID = zoneID
                }
                
                // Set Database Scope
                if let dbs = zoneDictionary["dbs"] as? NSNumber, let scope = CKDatabaseScope(rawValue: dbs.intValue) {
                    databaseScope = scope
                }
                
                // Set Subscription ID
                if let sid = zoneDictionary["sid"] as? String {
                    subscriptionID = sid
                }
                
            }
        }
    }
}
