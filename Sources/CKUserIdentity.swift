//
//  CKUserIdentity.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 14/07/2016.
//
//

import Foundation




public class CKUserIdentity : NSObject {
    
    
    // This is the lookupInfo you passed in to CKDiscoverUserIdentitiesOperation or CKFetchShareParticipantsOperation
    public let lookupInfo: CKUserIdentityLookupInfo?
    
    public let nameComponents: CKPersonNameComponentsType?
    
    public let userRecordID: CKRecordID?
    
    public let hasiCloudAccount: Bool
    
    var firstName: String?
    
    var lastName: String?
    
    public init(userRecordID: CKRecordID) {
        
        self.userRecordID = userRecordID
        
        self.lookupInfo = nil
        
        hasiCloudAccount = false
        
        nameComponents = nil
        
        super.init()
    }
    
    
    init?(dictionary: [String: AnyObject]) {
        
        if let lookUpInfoDictionary = dictionary["lookupInfo"] as? [String: AnyObject], lookupInfo = CKUserIdentityLookupInfo(dictionary: lookUpInfoDictionary) {
            self.lookupInfo = lookupInfo
        } else {
            self.lookupInfo = nil
        }
        
        if let userRecordName = dictionary["userRecordName"] as? String {
            self.userRecordID = CKRecordID(recordName: userRecordName)
        } else {
            self.userRecordID = nil
        }
        
        if let nameComponentsDictionary = dictionary["nameComponents"] as? [String: AnyObject] {
            if #available(OSX 10.11, *) {
                self.nameComponents = CKPersonNameComponents(dictionary: nameComponentsDictionary)
            } else {
                // Fallback on earlier versions
                self.nameComponents = CKPersonNameComponents(dictionary: nameComponentsDictionary)
            }
            
       //     self.firstName = nameComponents?.givenName
        //    self.lastName = nameComponents?.familyName
        } else {
            self.nameComponents = nil
        }
        
        self.hasiCloudAccount = false
        
        super.init()

    }
    
}
/*
extension PersonNameComponents {
    init?(dictionary: [String: AnyObject]) {
        self.init()
        
        namePrefix = dictionary["namePrefix"] as? String
        givenName = dictionary["givenName"] as? String
        familyName = dictionary["familyName"] as? String
        nickname = dictionary["nickname"] as? String
        nameSuffix = dictionary["nameSuffix"] as? String
        middleName = dictionary["middleName"] as? String
       // phoneticRepresentation
    }
}
 */
