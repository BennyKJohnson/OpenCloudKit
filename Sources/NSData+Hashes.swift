//
//  NSData+Hashes.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 9/07/2016.
//
//

import Foundation


extension NSData {
    
    func sha256Hash() -> NSData {
       return NSData(bytes: self.byteArray.sha256())
       
    }
    
}
