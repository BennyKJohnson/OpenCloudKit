//
//  Bridging.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/07/2016.
//
//

#if !os(Linux)
import Foundation
    
    public extension String {
        public func bridge() -> NSString {
            return self as NSString
        }
    }
    
    public extension NSString {
        func bridge() -> String {
            return self as String
        }
    }
    
    public extension Array where Element: AnyObject {
        public func bridge() -> NSArray {
            return self as NSArray
        }
    }
    
    //typealias Stringg = (String)
    
    extension NSArray {
        public func bridge() -> Array<AnyObject> {
            return self as Array<AnyObject>
        }
    }
    
    extension NSDictionary {
        public func bridge() -> [NSObject: AnyObject] {
            return self as [NSObject: AnyObject]
        }
    }
    
#endif
