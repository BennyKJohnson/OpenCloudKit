//
//  Bridging.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/07/2016.
//
//

import Foundation

public protocol _OCKBridgable {
    associatedtype ObjectType
    func bridge() -> ObjectType
}

public protocol CKNumberValueType: CKRecordValue {}
 extension CKNumberValueType where Self: _OCKBridgable, Self.ObjectType == NSNumber {
    public var recordFieldDictionary: [String: AnyObject] {
        return ["value": self.bridge()]
    }
}

extension String: _OCKBridgable {
    public typealias ObjectType = NSString
    
    public func bridge() -> NSString {
        return NSString(string: self)
    }
}

extension Int: _OCKBridgable {
    public typealias ObjectType = NSNumber
    
    public func bridge() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt: _OCKBridgable {
    public typealias ObjectType = NSNumber
    
    public func bridge() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension Float: _OCKBridgable {
    public typealias ObjectType = NSNumber
    
    public func bridge() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension Double: _OCKBridgable {
    public typealias ObjectType = NSNumber
    
    public func bridge() -> NSNumber {
        return NSNumber(value: self)
    }
}

#if !os(Linux)
    
    typealias NSErrorUserInfoType = [AnyHashable: Any]

    public extension NSString {
        func bridge() -> String {
            return self as String
        }
    }
    
    extension NSArray {
         func bridge() -> Array<Any> {
            return self as! Array<Any>
        }
    }
    
    extension NSDictionary {
        public func bridge() -> [NSObject: AnyObject] {
            return self as [NSObject: AnyObject]
        }
    }
    
    extension Dictionary {
        func bridge() -> NSDictionary {
            return self as NSDictionary
        }
    }
    
    extension Array {
        func bridge() -> NSArray {
            return self as NSArray
        }
    }
    
    extension Date {
        func bridge() -> NSDate {
            return self as NSDate
        }
    }
    
    extension NSDate {
        func bridge() -> Date {
            return self as Date
        }
    }
    
    extension NSData {
        func bridge() -> Data {
            return self as Data
        }
    }
    
    
    
#elseif os(Linux)
    
    typealias NSErrorUserInfoType = [String: Any]

    public extension NSString {
        func bridge() -> String {
            return self._bridgeToSwift()
        }
    }
    
    extension NSArray {
        public func bridge() -> Array<Any> {
            return self._bridgeToSwift()
        }
    }
    
    extension NSDictionary {
        public func bridge() -> [AnyHashable: Any] {
            return self._bridgeToSwift()
        }
    }
    
    extension Dictionary {
        func bridge() -> NSDictionary {
            return self._bridgeToObjectiveC()
        }
    }
    
    extension Array {
        public func bridge() -> NSArray {
            return self._bridgeToObjectiveC()
        }
    }
    
    extension NSData {
        public func bridge() -> Data {
            return self._bridgeToSwift()
        }
    }
    
    extension Date {
        public func bridge() -> NSDate {
            return self._bridgeToObjectiveC()
        }
    }
    
    extension NSDate {
        public func bridge() -> Date {
            return self._bridgeToSwift()
        }
    }
    
#endif

extension NSError {
    public convenience init(error: Error) {
        
        var userInfo: [String : Any] = [:]
        var code: Int = 0
        
        // Retrieve custom userInfo information.
        if let customUserInfoError = error as? CustomNSError {
            userInfo = customUserInfoError.errorUserInfo
            code = customUserInfoError.errorCode
        }
        
        if let localizedError = error as? LocalizedError {
            if let description = localizedError.errorDescription {
                userInfo[NSLocalizedDescriptionKey] = description
            }
            
            if let reason = localizedError.failureReason {
                userInfo[NSLocalizedFailureReasonErrorKey] = reason
            }
            
            if let suggestion = localizedError.recoverySuggestion {
                userInfo[NSLocalizedRecoverySuggestionErrorKey] = suggestion
            }
            
            if let helpAnchor = localizedError.helpAnchor {
                userInfo[NSHelpAnchorErrorKey] = helpAnchor
            }
          
        }
        
        if let recoverableError = error as? RecoverableError {
            userInfo[NSLocalizedRecoveryOptionsErrorKey] = recoverableError.recoveryOptions
         //   userInfo[NSRecoveryAttempterErrorKey] = recoverableError
       
        }
        
        self.init(domain: "OpenCloudKit", code: code, userInfo: userInfo)
        
    }
    
    
    
}





