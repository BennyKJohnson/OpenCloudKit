//
//  CKDatabaseNotification.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/1/17.
//
//

import Foundation

public class CKDatabaseNotification : CKNotification {
    
    public var databaseScope: CKDatabaseScope = .public
    
    override init(fromRemoteNotificationDictionary notificationDictionary: [AnyHashable : Any]) {
        
        super.init(fromRemoteNotificationDictionary: notificationDictionary)
        
        notificationType = .database
        
        if let ckDictionary = notificationDictionary["ck"] as? [String: Any] {
            if let metDictionary = ckDictionary["met"] as? [String: Any] {
                
                // Set database scope
                if let dbs = metDictionary["dbs"] as? NSNumber, let scope = CKDatabaseScope(rawValue: dbs.intValue)  {
                    databaseScope = scope
                }
                
                // Set Subscription ID
                if let sid = metDictionary["sid"] as? String {
                    subscriptionID = sid
                }
                
            }
        }
    }
}
