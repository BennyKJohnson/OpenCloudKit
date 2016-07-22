//
//  CKDictionaryValue.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 22/07/2016.
//
//

import Foundation
/*
protocol CKDictionaryValue {
    func toObject() -> AnyObject?
}

extension String: CKDictionaryValue {
    func toObject() -> AnyObject? {
        return self.bridge()
    }
}

extension Int: CKDictionaryValue {
    func toObject() -> AnyObject? {
        return NSNumber(value: self)
    }
}
extension Double: CKDictionaryValue {
    func toObject() -> AnyObject? {
        return NSNumber(value: self)
    }
}

extension Float: CKDictionaryValue {
    func toObject() -> AnyObject? {
        return NSNumber(value: self)
    }
}

extension Bool: CKDictionaryValue {
    func toObject() -> AnyObject? {
        return NSNumber(value: self)
    }
}

extension Array: CKDictionaryValue {
    func toObject() -> AnyObject? {
        return self.bridge() as? AnyObject
    }
}

extension Dictionary where Key: StringLiteralConvertible, Value: CKDictionaryValue {
    func toObject() -> AnyObject? {
        var dictionary: [String: AnyObject] = [:]
        
        for (key, value) in dictionary {
            dictionary[key] = value.toObject()
        }
        
        return dictionary
    }
}
 */
