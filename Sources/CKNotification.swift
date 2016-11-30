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

public class CKNotification : NSObject {
    
    
    init(notificationType: CKNotificationType) {
        self.notificationType = notificationType
        super.init()
    }
    
    public convenience init(fromRemoteNotificationDictionary notificationDictionary: [String : Any]) {
        
        self.init(notificationType: CKNotificationType.database)
        
    }
    
    public var notificationType: CKNotificationType = .database
    public var notificationID: CKNotificationID?
    public var containerIdentifier: String?
    
    
    /* push notifications have a limited size.  In some cases, CloudKit servers may not be able to send you a full
     CKNotification's worth of info in one push.  In those cases, isPruned returns YES.  The order in which we'll
     drop properties is defined in each CKNotification subclass below.
     The CKNotification can be obtained in full via a CKFetchNotificationChangesOperation */
    public let isPruned: Bool = false
    
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


