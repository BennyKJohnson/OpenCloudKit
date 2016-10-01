//
//  SortDescriptor.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 1/10/16.
//
//

import Foundation

#if os(Linux)
    public typealias NSSortDescriptor = SortDescriptor

    open class SortDescriptor: NSObject, NSSecureCoding, NSCopying {
        
        open var key: String?
        open var ascending: Bool
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        open func encode(with aCoder: NSCoder) {
            fatalError()
        }
    
        public init(key: String?, ascending: Bool) {
            self.key = key
            self.ascending = ascending
        }
        
        
        static public var supportsSecureCoding: Bool {
            return true
        }
        
        open override func copy() -> Any {
            return copy(with: nil)
        }
        
        open func copy(with zone: NSZone? = nil) -> Any {
            fatalError()
        }
        
    }
#endif
