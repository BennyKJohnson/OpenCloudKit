//
//  CKReference.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 27/08/2016.
//
//

import Foundation

public enum CKReferenceAction : UInt {
    case none
    case deleteSelf

    public init?(value: String) {
        switch value {
        case "NONE", "VALIDATE":
            self = .none
        case "DELETE_SELF":
            self = .deleteSelf
        default:
            return nil
        }
    }
}

extension CKReferenceAction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "NONE"
        case .deleteSelf:
            return "DELETE_SELF"
        }
    }
}

open class CKReference: NSObject {
    
    
    /* It is acceptable to relate two records that have not yet been uploaded to the server, but those records must be uploaded to the server in the same operation.
     If a record references a record that does not exist on the server and is not in the current save operation it will result in an error. */
    public init(recordID: CKRecordID, action: CKReferenceAction) {
        self.recordID = recordID
        self.referenceAction = action
    }
    
    public convenience init(record: CKRecord, action: CKReferenceAction) {
        self.init(recordID: record.recordID, action: action)
    }
    
    public let referenceAction: CKReferenceAction
    
    public let recordID: CKRecordID
}

extension CKReference {
    
    convenience init?(dictionary: [String: Any]) {
        
      guard
        let recordName = dictionary["recordName"] as? String,
        let actionValue = dictionary["action"] as? String,
        let action = CKReferenceAction(value: actionValue)
        else {
            return nil
        }
        
        let recordID: CKRecordID
        if let zoneDictionary = dictionary["zoneID"] as? [String: Any],
            let zoneID = CKRecordZoneID(dictionary: zoneDictionary) {
            recordID = CKRecordID(recordName: recordName, zoneID: zoneID)
        } else {
           recordID = CKRecordID(recordName: recordName)
        }
        
        self.init(recordID: recordID, action: action)
    }
    
    var dictionary: [String: Any] {
        let dict: [String: Any] = ["recordName": recordID.recordName.bridge(), "zoneID": recordID.zoneID.dictionary.bridge(), "action": referenceAction.description.bridge()]
        
        return dict
    }
    
}
