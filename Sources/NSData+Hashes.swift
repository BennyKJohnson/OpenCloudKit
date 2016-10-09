//
//  NSData+Hashes.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 9/07/2016.
//
//

import Foundation
import COpenSSL

/*

extension NSData {
    
    func sha256() -> NSData {
        
        let shaContext = UnsafeMutablePointer<SHA256_CTX>.allocate(capacity: 1)//(allocatingCapacity: 1)
        SHA256_Init(shaContext)
        SHA256_Update(shaContext, self.bytes, self.length)
        
        var hash = [UInt8](repeating: 0, count: Int(SHA256_DIGEST_LENGTH))
        SHA256_Final(&hash, shaContext)
        
        shaContext.deallocate(capacity: 1)
        
        return NSData(bytes: hash, length: hash.count)
        
    }
    
}
*/
