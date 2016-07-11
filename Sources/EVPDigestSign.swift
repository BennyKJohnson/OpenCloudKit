//
//  EVPDigestSign.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 10/07/2016.
//
//

import Foundation
import COpenSSL

public enum MessageDigestError: ErrorProtocol {
    case unknownDigest
}

public final class MessageDigest {
    static var addedAllDigests = false
    let messageDigest: UnsafeMutablePointer<EVP_MD>
    

    public init(_ messageDigest: String) throws {
        if !MessageDigest.addedAllDigests {
            OpenSSL_add_all_digests()
            MessageDigest.addedAllDigests = true
        }
        
        guard let messageDigest = messageDigest.withCString({EVP_get_digestbyname($0)}) else {
            throw MessageDigestError.unknownDigest
        }
        
        self.messageDigest = UnsafeMutablePointer(messageDigest)
    }
}

public enum MessageDigestContextError: ErrorProtocol {
    case initializationFailed
    case updateFailed
    case signFailed
    case privateKeyLoadFailed
}

public final class MessageDigestContext {
    let context: UnsafeMutablePointer<EVP_MD_CTX>
    
    deinit {
        EVP_MD_CTX_destroy(context)
    }
    
    
    public init(_ messageDigest: MessageDigest) throws {
        let context: UnsafeMutablePointer<EVP_MD_CTX>! = EVP_MD_CTX_create()
        
        if EVP_DigestInit(context, messageDigest.messageDigest) == 0 {
            throw MessageDigestContextError.initializationFailed
        }
        
        guard let c = context else {
            throw MessageDigestContextError.initializationFailed
        }
        
        self.context = c
    }
    
    public func update(_ data: NSData) throws {

        if EVP_DigestUpdate(context, data.bytes, data.length) == 0 {
            throw MessageDigestContextError.updateFailed
        }
    }
    
    public func sign(privateKeyURL: String, passPhrase: String? = nil) throws -> NSData {


        // Load Private Key
        let privateKeyFilePointer = BIO_new_file(privateKeyURL, "r")
        guard let privateKeyFile = privateKeyFilePointer else {
            fatalError("Unable to load key file")
        }
        
        guard let privateKey  = PEM_read_bio_PrivateKey(privateKeyFile, nil, nil, nil) else {
            throw MessageDigestContextError.privateKeyLoadFailed
        }
        
        if ERR_peek_error() != 0 {
            throw MessageDigestContextError.signFailed
        }
        
        var length: UInt32 = 8192
        var signature = [UInt8](repeating: 0, count: Int(length))
        
        if EVP_SignFinal(context, &signature, &length, privateKey) == 0 {
            throw MessageDigestContextError.signFailed
        }
        
        EVP_PKEY_free(privateKey)
        BIO_free_all(privateKeyFilePointer)
        
        let signatureBytes = Array(signature.prefix(upTo: Int(length)))
        return NSData(bytes: signatureBytes)
    }
}



