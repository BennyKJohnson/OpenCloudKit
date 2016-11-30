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
    func toObject() -> Any?
}

extension String: CKDictionaryValue {
    func toObject() -> Any? {
        return self.bridge()
    }
}

extension Int: CKDictionaryValue {
    func toObject() -> Any? {
        return NSNumber(value: self)
    }
}
extension Double: CKDictionaryValue {
    func toObject() -> Any? {
        return NSNumber(value: self)
    }
}

extension Float: CKDictionaryValue {
    func toObject() -> Any? {
        return NSNumber(value: self)
    }
}

extension Bool: CKDictionaryValue {
    func toObject() -> Any? {
        return NSNumber(value: self)
    }
}

extension Array: CKDictionaryValue {
    func toObject() -> Any? {
        return self.bridge() as? Any
    }
}

extension Dictionary where Key: StringLiteralConvertible, Value: CKDictionaryValue {
    func toObject() -> Any? {
        var dictionary: [String: Any] = [:]
        
        for (key, value) in dictionary {
            dictionary[key] = value.toObject()
        }
        
        return dictionary
    }
}
 */
