//
//  Bridging.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/07/2016.
//
//

protocol Bridgable {
}



extension String: Bridgable {}
extension Int: Bridgable {}
extension Float: Bridgable {}
extension Double: Bridgable {}

import Foundation

public extension String {
    public func bridge() -> NSString {
        return NSString(string: self)
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
        public func bridge() -> Array<Any> {
            return self as! Array<Any>
        }
    }
    
    extension NSDictionary {
        public func bridge() -> [NSObject: AnyObject] {
            return self as [NSObject: AnyObject]
        }
    }
    
    extension Dictionary {
        public func bridge() -> NSDictionary {
            return self as NSDictionary
        }
    }
    
    extension Array {
        public func bridge() -> NSArray {
            return self as NSArray
        }
    }
    
    extension NSData {
        public func bridge() -> Data {
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
        public func bridge() -> NSDictionary {
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





