//
//  EVPDigestSign.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 10/07/2016.
//
//

import Foundation
import CLibreSSL

public enum MessageDigestError: Error {
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
        
        self.messageDigest = UnsafeMutablePointer(mutating: messageDigest)
    }
}

public enum MessageDigestContextError: Error {
    case initializationFailed
    case updateFailed
    case signFailed
    case privateKeyLoadFailed
    case privateKeyNotFound
}

public enum EVPKeyType {
    case Public
    case Private
}

public final class EVPKey {
    
    let pkey: UnsafeMutablePointer<EVP_PKEY>!
    let type: EVPKeyType
    
    deinit {
        EVP_PKEY_free(pkey)
    }
    
    public init(contentsOfFile path: String, type: EVPKeyType) throws {
        // Load Private Key
        let filePointer = BIO_new_file(path, "r")
        guard let file = filePointer else {
            throw MessageDigestContextError.privateKeyNotFound
        }
        
        self.type = type
        
        switch type {
        case .Private:
            guard let privateKey  = PEM_read_bio_PrivateKey(file, nil, nil, nil) else {
                throw MessageDigestContextError.privateKeyLoadFailed
            }
            pkey = privateKey

        case .Public:
            guard let publicKey = PEM_read_bio_PUBKEY(file, nil, nil, nil) else {
                throw MessageDigestContextError.privateKeyLoadFailed
            }
            pkey = publicKey
        }
      
        BIO_free_all(file)
    }
}

public final class MessageVerifyContext {
    
    let context: UnsafeMutablePointer<EVP_MD_CTX>

    deinit {
        EVP_MD_CTX_destroy(context)
    }
    
    public init(_ messageDigest: MessageDigest, withKey key: EVPKey) throws {
        
        let context: UnsafeMutablePointer<EVP_MD_CTX>! = EVP_MD_CTX_create()
        
        if EVP_DigestVerifyInit(context, nil, messageDigest.messageDigest, nil, key.pkey) == 0 {
            throw MessageDigestContextError.initializationFailed
        }
        
        guard let c = context else {
            throw MessageDigestContextError.initializationFailed
        }
        
        self.context = c
    }
    
    // Message
    func update(data: NSData) throws {
        
        if EVP_DigestUpdate(context, data.bytes, data.length) == 0 {
            throw MessageDigestContextError.updateFailed
        }
        
    }
    
    // Signature
    func verify(signature: NSData) -> Bool {
        
        let typedPointer = signature.bytes.bindMemory(to: UInt8.self, capacity: signature.length)
        var bytes = Array(UnsafeBufferPointer(start: typedPointer, count: signature.length))
        
        return EVP_DigestVerifyFinal(context, &bytes, bytes.count) == 1
    }
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
            throw MessageDigestContextError.privateKeyNotFound
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
        
      
        return  NSData(bytes: signatureBytes, length: signatureBytes.count)
    }
}



