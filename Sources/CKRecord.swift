//
//  CKRecord.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation

public let CKRecordTypeUserRecord: String = "Users"

public protocol CKRecordValue : NSObjectProtocol {}

public class CKRecord: NSObject {
    
    var values: [String: CKRecordValue] = [:]
    
    public let recordType: String
    
    public let recordID: CKRecordID
    
    public var recordChangeTag: String?
    
    /* This is a User Record recordID, identifying the user that created this record. */
    public var creatorUserRecordID: CKRecordID?
    
    public var creationDate = NSDate()
    
    /* This is a User Record recordID, identifying the user that last modified this record. */
    public var lastModifiedUserRecordID: CKRecordID?
    
    public var modificationDate: NSDate?
    
    private var changedKeysSet = NSMutableSet()
    
    public convenience init(recordType: String) {
        let UUID = NSUUID().uuidString
        self.init(recordType: recordType, recordID: CKRecordID(recordName: UUID))
    }
    
    public init(recordType: String, recordID: CKRecordID) {
        self.recordID = recordID
        self.recordType = recordType
    }
    
    public func object(forKey key: String) -> CKRecordValue? {
        return values[key]
    }
    
    public func setObject(_ object: CKRecordValue?, forKey key: String) {
        if !changedKeysSet.contains(key) {
            changedKeysSet.add(key)
        }
        
        values[key] = object
    }

    public func allKeys() -> [String] {
       return Array(values.keys)
    }

    public subscript(key: String) -> CKRecordValue? {
        get {
            return object(forKey: key)
        }
        set(newValue) {
            setObject(newValue, forKey: key)
        }
    }
    
    public func changedKeys() -> [String] {
        return changedKeysSet.allObjects as! [String]
    }
    
    override public var description: String {
        return "<\(self.dynamicType): \(unsafeAddress(of: self)); recordType = \(recordType);recordID = \(recordID); values = \(values)>"
    }
    
    public override var debugDescription: String {
        return"<\(self.dynamicType): \(unsafeAddress(of: self)); recordType = \(recordType);recordID = \(recordID); values = \(values)>"
    }
}

struct CKRecordDictionary {
    static let recordName = "recordName"
    static let recordType = "recordType"
    static let recordChangeTag = "recordChangeTag"
    static let fields = "fields"
    static let zoneID = "zoneID"
    static let modified = "modified"
    static let created = "created"
}

struct CKRecordFieldDictionary {
    static let value = "value"
    static let type = "type"
}


class CKAsset: NSObject {
    
    @NSCopying var fileURL : NSURL
    
    init(fileURL: NSURL) {
        self.fileURL = fileURL
    }
}

struct CKValueType {
    static let string = "STRING"
    static let data = "BYTES"
}

struct CKRecordLog {
    let timestamp: TimeInterval
    let userRecordName: String
    let deviceID: String
    
    init?(dictionary: [String: AnyObject]) {
        guard let timestamp = (dictionary["timestamp"] as? NSNumber)?.doubleValue, userRecordName = dictionary["userRecordName"] as? String, deviceID =  dictionary["deviceID"] as? String else {
            return nil
        }
        
        self.timestamp = timestamp
        self.userRecordName = userRecordName
        self.deviceID = deviceID
    }
}


extension CKRecord {
    
    func fieldsDictionary(forKeys keys: [String]) -> [String: AnyObject] {
        
        var fieldsDictionary: [String: AnyObject] = [:]
        
        for key in keys {
            if let value = object(forKey: key) {
                let valueDictionary: [String: AnyObject]
                switch value {
                default:
                    valueDictionary = ["value": value]
                }
                fieldsDictionary[key] = valueDictionary
            }
        }
        
        return fieldsDictionary
        
    }
    
    var dictionary: [String: AnyObject] {
        
        // Add Fields
        var fieldsDictionary: [String: AnyObject] = [:]
        for (key, value) in values {
            let valueDictionary: [String: AnyObject]
            
            switch value {
            default:
                 valueDictionary = ["value": value]

            }
            
            fieldsDictionary[key] = valueDictionary
        }
        
        
        let recordDictionary: [String: AnyObject] = [
        "fields": fieldsDictionary,
        "recordType": recordType,
        "recordName": recordID.recordName
        ]
        
        return recordDictionary
    }
    
    static func recordValue(forValue value: AnyObject) -> CKRecordValue {
        switch value {
        case let number as NSNumber:
           return number
            
        default:
            fatalError("Not Supported")
        }
    }
    
    static func value(forRecordField field: [String: AnyObject]) -> CKRecordValue? {
        if  let value = field[CKRecordFieldDictionary.value],
            let type = field[CKRecordFieldDictionary.type] as? String {
        
            switch value {
            case let number as NSNumber:
                switch(type) {
                case "TIMESTAMP":
                    return NSDate(timeIntervalSince1970: number.doubleValue)
                default:
                    return number
                }
                
            case let dictionary as [String: AnyObject]:
                switch type {
                
                case "LOCATION":
                    let latitude = (dictionary["latitude"] as! NSNumber).doubleValue
                    let longitude = (dictionary["longitude"] as! NSNumber).doubleValue
                    
                    return Location(latitude: latitude, longitude: longitude)
                default:
                    fatalError("Type not supported")
                }
                
            case let boolean as Bool:
                return NSNumber(booleanLiteral: boolean)
                
            case let string as String:
                switch type {
                case CKValueType.string:
                    return NSString(string: string)
                case CKValueType.data:
                    return NSData(base64Encoded: string)
                default:
                    return NSString(string: string)
                }
                
            case let array as [AnyObject]:
                switch type {
                case "INT64_LIST":
                    let numberArray =  array as! [NSNumber]
                   return NSArray(array: numberArray)
                case "STRING_LIST":
                    let stringArray =  array as! [String]
                    return NSArray(array: stringArray)
                case "TIMESTAMP_LIST":
                    let dateArray = (array as! [NSNumber]).map({ (dateInterval) -> NSDate in
                        return  NSDate(timeIntervalSince1970: dateInterval.doubleValue)
                    })
                    return NSArray(array: dateArray)
                    
                default:
                    fatalError("List type of \(type) not supported")
                }
             
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    convenience init?(recordDictionary: [String: AnyObject]) {
        
        guard let recordName = recordDictionary[CKRecordDictionary.recordName] as? String,
            recordType = recordDictionary[CKRecordDictionary.recordType] as? String
        else {
                return nil
        }
        
        // Parse ZoneID Dictionary into CKRecordZoneID
        let zoneID: CKRecordZoneID
        if let zoneIDDictionary = recordDictionary[CKRecordDictionary.zoneID] as? [String: AnyObject] {
            zoneID = CKRecordZoneID(dictionary: zoneIDDictionary)!
        } else {
            zoneID = CKRecordZoneID(zoneName: CKRecordZoneDefaultName, ownerName: "_defaultOwner")
        }

        let recordID = CKRecordID(recordName: recordName, zoneID: zoneID)
        self.init(recordType: recordType, recordID: recordID)
        
        // Parse Record Change Tag
        if let changeTag = recordDictionary[CKRecordDictionary.recordChangeTag] as? String {
            recordChangeTag = changeTag
        }
        
        // Parse Created Dictionary
        if let createdDictionary = recordDictionary[CKRecordDictionary.created] as? [String: AnyObject], created = CKRecordLog(dictionary: createdDictionary) {
            self.creatorUserRecordID = CKRecordID(recordName: created.userRecordName)
            self.creationDate = NSDate(timeIntervalSince1970: created.timestamp)
        }
        
        // Parse Modified Dictionary
        if let modifiedDictionary = recordDictionary[CKRecordDictionary.modified] as? [String: AnyObject], modified = CKRecordLog(dictionary: modifiedDictionary) {
            self.lastModifiedUserRecordID = CKRecordID(recordName: modified.userRecordName)
            self.modificationDate = NSDate(timeIntervalSince1970: modified.timestamp)
        }
        
        // Enumerate Fields
        if let fields = recordDictionary[CKRecordDictionary.fields] as? [String: [String: AnyObject]] {
            for (key, fieldValue) in fields  {
                let value = CKRecord.value(forRecordField: fieldValue)
                values[key] = value
            }
        }
    }
    
}
