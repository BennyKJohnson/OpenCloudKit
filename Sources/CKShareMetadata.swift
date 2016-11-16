//
//  CKShareMetadata.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 16/10/16.
//
//

import Foundation

extension Bool {
    var number: NSNumber {
        if self == true {
            return NSNumber(value: 1)
        } else {
            return NSNumber(value: 0)

        }
    }
}

public struct CKShortGUID {
    
    public let value: String
    
    public let shouldFetchRootRecord: Bool
    
    public  let rootRecordDesiredKeys: [String]?
    
    public var dictionary: [String: AnyObject] {
        let dict:[String: AnyObject] = ["value": value.bridge(),
                                        "shouldFetchRootRecord": shouldFetchRootRecord.number]
        return dict
    }
    
    public init(value: String, shouldFetchRootRecord: Bool, rootRecordDesiredKeys: [String]? = nil) {
        self.value = value
        self.shouldFetchRootRecord = shouldFetchRootRecord
        self.rootRecordDesiredKeys = rootRecordDesiredKeys
    }
    
}

open class CKShareMetadata  {
    
    init() {
        
        containerIdentifier = ""
        
    }
    
    open var containerIdentifier: String
    
    open var share: CKShare?
    
    open var rootRecordID: CKRecordID?
    
    /* These properties reflect the participant properties of the user invoking CKFetchShareMetadataOperation */
    open var participantType: CKShareParticipantType = .unknown
    
    open var participantStatus: CKShareParticipantAcceptanceStatus = .unknown
    
    open var participantPermission: CKShareParticipantPermission = CKShareParticipantPermission.unknown
    
    
    open var ownerIdentity: CKUserIdentity?
    
    
    /* This is only present if the share metadata was returned from a CKFetchShareMetadataOperation with shouldFetchRootRecord set to YES */
    open var rootRecord: CKRecord?
    
    init?(dictionary:[String: AnyObject]) {
        /*
        if let dictionary = CKFetchErrorDictionary(dictionary: dictionary) {
            return nil
        }
        */
        
        containerIdentifier = dictionary["containerIdentifier"] as! String
        
        let rootRecordName = dictionary["rootRecordName"] as! String
        
        let zoneID = CKRecordZoneID(dictionary: dictionary["zoneID"] as! [String:AnyObject])!
        
        rootRecordID = CKRecordID(recordName: rootRecordName, zoneID: zoneID)
        
        // Set participant type
        let rawParticipantType = dictionary["participantType"] as! String
        participantType = CKShareParticipantType(string: rawParticipantType)!
        
        // Set participant permission 
        if let rawParticipantPermission = dictionary["participantPermission"] as? String, let permission = CKShareParticipantPermission(string: rawParticipantPermission) {
            participantPermission = permission
        }
        

        // Set status
        if let rawParticipantStatus = dictionary["participantStatus"] as? String, let status = CKShareParticipantAcceptanceStatus(string: rawParticipantStatus) {
            participantStatus = status
        }

        
        if let ownerIdentityDictionary = dictionary["ownerIdentity"] as? [String: AnyObject] {
            ownerIdentity = CKUserIdentity(dictionary: ownerIdentityDictionary)
        }
        
        // Set root record if available
        if let rootRecordDictionary = dictionary["rootRecord"] as? [String: AnyObject] {
            rootRecord = CKRecord(recordDictionary: rootRecordDictionary)
        }
        
    }
}
