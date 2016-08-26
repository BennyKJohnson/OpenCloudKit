//
//  CKUserIdentityLookupInfo.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 14/07/2016.
//
//

import Foundation

public class CKUserIdentityLookupInfo : NSObject {
    
    public init(emailAddress: String) {
        self.emailAddress = emailAddress
        self.phoneNumber = nil
        self.userRecordID = nil
    }
    
    public init(phoneNumber: String) {
        self.emailAddress = nil
        self.phoneNumber = phoneNumber
        self.userRecordID = nil
    }
    
    public init(userRecordID: CKRecordID) {
        self.emailAddress = nil
        self.phoneNumber = nil
        self.userRecordID = userRecordID
    }
    
    public init(emailAddress: String, phoneNumber: String, userRecordID: CKRecordID) {
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.userRecordID = userRecordID
    }
    
    public class func lookupInfos(withEmails emails: [String]) -> [CKUserIdentityLookupInfo] {
        return emails.map({ (email) -> CKUserIdentityLookupInfo in
            return CKUserIdentityLookupInfo(emailAddress: email)
        })
    }
    
    public class func lookupInfos(withPhoneNumbers phoneNumbers: [String]) -> [CKUserIdentityLookupInfo] {
        return phoneNumbers.map({ (phoneNumber) -> CKUserIdentityLookupInfo in
            return CKUserIdentityLookupInfo(phoneNumber: phoneNumber)
        })
    }
    
    public class func lookupInfos(with recordIDs: [CKRecordID]) -> [CKUserIdentityLookupInfo] {
        return recordIDs.map({ (recordID) -> CKUserIdentityLookupInfo in
            return CKUserIdentityLookupInfo(userRecordID: recordID)
        })
    }
    
    public let emailAddress: String?
    
    public let phoneNumber: String?
    
    public let userRecordID: CKRecordID?
}

extension CKUserIdentityLookupInfo: CKCodable {
    convenience init?(dictionary: [String: AnyObject]) {
        
        guard let emailAddress = dictionary["emailAddress"] as? String,
        let phoneNumber = dictionary["phoneNumber"] as? String,
        let userRecordName = dictionary["userRecordName"] as? String else {
                return nil
        }
        
        self.init(emailAddress: emailAddress, phoneNumber: phoneNumber, userRecordID: CKRecordID(recordName: userRecordName))
    }
    
    var dictionary: [String: Any] {
        
        var lookupInfo: [String: AnyObject] = [:]
        lookupInfo["emailAddress"] = emailAddress?.bridge()
        lookupInfo["phoneNumber"] = phoneNumber?.bridge()
        lookupInfo["userRecordName"] = userRecordID?.recordName.bridge()
        
        return lookupInfo
    }
}
