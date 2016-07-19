//
//  CKAsset.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 16/07/2016.
//
//

import Foundation

public class CKAsset: NSObject {
    
    public var fileURL : NSURL
    
    var recordKey: String?
    
    var uploaded: Bool = false
    
    var downloaded: Bool = false
    
    var recordID: CKRecordID?
    
    var downloadBaseURL: String?
        
    var downloadURL: URL? {
        get {
            if let downloadBaseURL = downloadBaseURL {
                return URL(string: downloadBaseURL)!
            } else {
                return nil
            }
        }
    }
    
    var size: UInt?
    
    var hasSize: Bool {
        return size != nil
    }
    
    var uploadReceipt: String?
    
    public init(fileURL: NSURL) {
        self.fileURL = fileURL
    }
    
    init?(dictionary: [String: AnyObject]) {
        
        guard let downloadURL = dictionary["downloadURL"] as? String,
        size = dictionary["size"] as? NSNumber
        else  {
            return nil
        }
        
        fileURL = NSURL()
        self.downloadBaseURL = downloadURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        self.size = size.uintValue
        downloaded = false

    }
}

extension CKAsset: CustomDictionaryConvertible {
    var dictionary: [String: AnyObject] {
        var fieldDictionary: [String: AnyObject] = [:]
        if let recordID = recordID, recordKey = recordKey {
            fieldDictionary["recordName"] = recordID.recordName
            fieldDictionary["recordType"] = "Items"
            fieldDictionary["fieldName"] = recordKey
        }
        
        return fieldDictionary
    }
}
