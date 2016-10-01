//
//  CKRecord.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation

public let CKRecordTypeUserRecord: String = "Users"
public protocol CKRecordFieldProvider {
    var recordFieldDictionary: [String: AnyObject] { get }
}
extension CKRecordFieldProvider where Self: AnyObject {
    public var recordFieldDictionary: [String: AnyObject] {
        return ["value": self]
    }
}
/*
extension CKRecordFieldProvider where Self: CustomDictionaryConvertible {
    public var recordFieldDictionary: [String: AnyObject] {
        return ["value": self.dictionary]
    }
}
*/
public protocol CKRecordValue : CKRecordFieldProvider, NSObjectProtocol {}



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
     
        let containsKey = changedKeysSet.contains(key)
      
        
        if !containsKey {
            changedKeysSet.add(key.bridge())
        }
        
        switch object {
        case let asset as CKAsset:
            asset.recordID = self.recordID
        default:
            break
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
        var changedKeysArray: [String] = []
        for changedKey in changedKeysSet.allObjects {
            if let key = (changedKey as? NSString)?.bridge() {
                changedKeysArray.append(key)
            }
        }
        
        return changedKeysArray
    }
    
 
    override public var description: String {
        return "<\(type(of: self)): ; recordType = \(recordType);recordID = \(recordID); values = \(values)>"
    }
    
    public override var debugDescription: String {
        return"<\(type(of: self)); recordType = \(recordType);recordID = \(recordID); values = \(values)>"
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

struct CKValueType {
    static let string = "STRING"
    static let data = "BYTES"
}

struct CKRecordLog {
    let timestamp: TimeInterval
    let userRecordName: String
    let deviceID: String
    
    init?(dictionary: [String: AnyObject]) {
        guard let timestamp = (dictionary["timestamp"] as? NSNumber)?.doubleValue, let userRecordName = dictionary["userRecordName"] as? String, let deviceID =  dictionary["deviceID"] as? String else {
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
                fieldsDictionary[key] = value.recordFieldDictionary.bridge() as NSDictionary
            }
        }
        
        return fieldsDictionary
        
    }
    
    var dictionary: [String: AnyObject] {
        
        // Add Fields
        var fieldsDictionary: [String: AnyObject] = [:]
        for (key, value) in values {
            fieldsDictionary[key] = value.recordFieldDictionary.bridge() as NSDictionary
        }
        
        
        let recordDictionary: [String: AnyObject] = [
        "fields": fieldsDictionary.bridge() as NSDictionary,
        "recordType": recordType.bridge(),
        "recordName": recordID.recordName.bridge()
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
    
    static func getValue(forRecordField field: [String: AnyObject]) -> CKRecordValue? {
        #if !os(Linux)
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
                    
                    return CKLocation(latitude: latitude, longitude: longitude)
                case "ASSETID":
                    // size
                    // downloadURL
                    // fileChecksum
                    return CKAsset(dictionary: dictionary)
                case "REFERENCE":
                    return CKReference(dictionary: dictionary)
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
                    #if os(Linux)
                        return NSData(base64Encoded: string,
                               options: [])
                    #else
                        return NSData(base64Encoded: string)
                    #endif
                default:
                    return NSString(string: string)
                }
                
            case let array as [AnyObject]:
                switch type {
                case "INT64_LIST":
                    let numberArray =  array as! [NSNumber]
                   return NSArray(array: numberArray)
                case "STRING_LIST":
                   // let stringArray =  array.bridge() as! [String]
                    return array.bridge()
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
        #else
            return nil
        #endif
    }
    
    convenience init?(recordDictionary: [String: AnyObject]) {
        
        guard let recordName = recordDictionary[CKRecordDictionary.recordName] as? String,
            let recordType = recordDictionary[CKRecordDictionary.recordType] as? String
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
        if let createdDictionary = recordDictionary[CKRecordDictionary.created] as? [String: AnyObject], let created = CKRecordLog(dictionary: createdDictionary) {
            self.creatorUserRecordID = CKRecordID(recordName: created.userRecordName)
            self.creationDate = NSDate(timeIntervalSince1970: created.timestamp)
        }
        
        // Parse Modified Dictionary
        if let modifiedDictionary = recordDictionary[CKRecordDictionary.modified] as? [String: AnyObject], let modified = CKRecordLog(dictionary: modifiedDictionary) {
            self.lastModifiedUserRecordID = CKRecordID(recordName: modified.userRecordName)
            self.modificationDate = NSDate(timeIntervalSince1970: modified.timestamp)
        }
        
        // Enumerate Fields
        if let fields = recordDictionary[CKRecordDictionary.fields] as? [String: [String: AnyObject]] {
            for (key, fieldValue) in fields  {
                let value = CKRecord.getValue(forRecordField: fieldValue)
                values[key] = value
            }
        }
    }
    
}

extension NSString : CKRecordValue {
    public var recordFieldDictionary: [String : AnyObject] {
        return ["value": self, "type":"STRING".bridge()]
    }
}

extension NSNumber : CKRecordValue {}

extension NSArray : CKRecordValue {}

extension NSDate : CKRecordValue {
    public var recordFieldDictionary: [String : AnyObject] {
        return ["value": NSNumber(value: self.timeIntervalSince1970), "type":"TIMESTAMP".bridge()]
    }
}

extension NSData : CKRecordValue {}

extension CKAsset: CKRecordValue {}

extension CKReference: CKRecordValue {
    public var recordFieldDictionary: [String: AnyObject] {
        return ["value": self.dictionary.bridge() as AnyObject, "type": "REFERENCE".bridge()]
    }
}

extension CKLocation: CKRecordValue {
    public var recordFieldDictionary: [String: AnyObject] {
        
        return ["value": self.dictionary.bridge() as AnyObject, "type": "LOCATION".bridge()]
    }
}

extension CKLocationType {
    public var recordFieldDictionary: [String: AnyObject] {
        return ["value": self.dictionary.bridge() as AnyObject, "type": "LOCATION".bridge()]
    }
}
