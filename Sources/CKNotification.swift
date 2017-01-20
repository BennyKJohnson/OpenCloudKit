//
//  CKNotification.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 16/07/2016.
//
//

import Foundation

public struct CKNotificationID {
    let notificationUUID: String
}

public enum CKNotificationType : Int {
    case query
    case recordZone
    case readNotification
    case database
}

let CKNotificationAPSAlertBodyKey = "body"
let CKNotificationCKKey = "ck"
let CKNotificiationAPSAlertLaunchImageKey = "launch-image"
let CKNotificationAPSAlertBadgeKey = "badge"
let CKNotificationQueryNotificationKey = "qry"
let CKNotificationZoneNotificationKey = "fet"
let CKNotificationDatabaseNotificationKey = "met"
let CKNotificationContainerIDKey = "cid"


public class CKNotification : NSObject {

    class func notification(fromRemoteNotificationDictionary notificationDictionary: [AnyHashable : Any]) -> CKNotification? {
        
        if let cloudKitDictionary = notificationDictionary[CKNotificationCKKey] as? [String: Any] {
            
            if cloudKitDictionary[CKNotificationQueryNotificationKey] as? [String: Any] != nil {
                return CKQueryNotification(fromRemoteNotificationDictionary: notificationDictionary)
            } else if cloudKitDictionary[CKNotificationZoneNotificationKey] as? [String: Any] != nil {
                return CKRecordZoneNotification(fromRemoteNotificationDictionary: notificationDictionary)
            } else if cloudKitDictionary[CKNotificationDatabaseNotificationKey] as? [String: Any] != nil {
                return CKDatabaseNotification(fromRemoteNotificationDictionary: notificationDictionary)
            }
        }
        
        return nil
    }
    
  
    
    init(fromRemoteNotificationDictionary notificationDictionary: [AnyHashable : Any])
    {
        super.init()

        notificationType = .database

        // Check that this notification is a CloudKit notification, if not return nil
        if let ckDictionary = notificationDictionary[CKNotificationCKKey] as? [String: Any] {
            
            // Get the container ID from dictionary
            if let containerID = ckDictionary[CKNotificationContainerIDKey] as? String {
                containerIdentifier = containerID
            }
            
            // Get the notification ID from dictionary
            if let nID = ckDictionary["nid"] as? String {
                let id = CKNotificationID(notificationUUID: nID)
                notificationID = id
            }
            
            // Set isPruned from dictionary
            if ckDictionary["p"] != nil  {
                isPruned = true
            }
            
        }
        
        if let apsDictionary = notificationDictionary["aps"] as? [String: Any] {
            if let alertDictionary = apsDictionary["alert"] as? [String: Any] {
                
                // Set body
                if let body = alertDictionary[CKNotificationAPSAlertBodyKey] as? String {
                    alertBody = body
                }
                
                // Set Alert Localization Key
                if let locKey = alertDictionary["loc-key"] as? String {
                    alertLocalizationKey = locKey
                }
                
                // Set Alert LocalizationArgs
                if let locArgs = alertDictionary["loc-args"] as? [String] {
                    self.alertLocalizationArgs = locArgs
                }
                
                // Set Action Localization Key
                if let actionLocKey = alertDictionary["action-loc-key"] as? String {
                    alertActionLocalizationKey = actionLocKey
                }
                
                // Set Launch Image
                if let launchImage = alertDictionary[CKNotificiationAPSAlertLaunchImageKey] as? String {
                    alertLaunchImage = launchImage
                }
                
                // Set Badge
                if let badgeVale = alertDictionary[CKNotificationAPSAlertBadgeKey] as? NSNumber {
                    badge = badgeVale
                }
                
                // Set Sound Name
                if let sound = alertDictionary["sound"] as? String {
                    soundName = sound
                }
                
                // Set Category
                if let cat = alertDictionary["category"] as? String {
                    category = cat
                }
            }
        }
    }
    
    public var notificationType: CKNotificationType = .database
    public var notificationID: CKNotificationID?
    public var containerIdentifier: String?
    
    
    /* push notifications have a limited size.  In some cases, CloudKit servers may not be able to send you a full
     CKNotification's worth of info in one push.  In those cases, isPruned returns YES.  The order in which we'll
     drop properties is defined in each CKNotification subclass below.
     The CKNotification can be obtained in full via a CKFetchNotificationChangesOperation */
    public var isPruned: Bool = false
    
    /* These keys are parsed out of the 'aps' payload from a remote notification dictionary.
     On tvOS, alerts, badges, sounds, and categories are not handled in push notifications. */
    
    /* Optional alert string to display in a push notification. */
    public var alertBody: String?
    
    /* Instead of a raw alert string, you may optionally specify a key for a localized string in your app's Localizable.strings file. */
    public var alertLocalizationKey: String?
    
    /* A list of field names to take from the matching record that is used as substitution variables in a formatted alert string. */
    public var alertLocalizationArgs: [String]?
    
    /* A key for a localized string to be used as the alert action in a modal style notification. */
    public var alertActionLocalizationKey: String?
    
    /* The name of an image in your app bundle to be used as the launch image when launching in response to the notification. */
    public var alertLaunchImage: String?
    
    /* The number to display as the badge of the application icon */
    @NSCopying public var badge: NSNumber?
    
    /* The name of a sound file in your app bundle to play upon receiving the notification. */
    public var soundName: String?
    
    /* The ID of the subscription that caused this notification to fire */
    public var subscriptionID: String?
    
    /* The category for user-initiated actions in the notification */
    public var category: String?
}

public enum CKQueryNotificationReason : Int {
    
    case recordCreated
    
    case recordUpdated
    
    case recordDeleted
}


