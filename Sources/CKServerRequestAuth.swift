//
//  CKServerRequestAuth.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 11/07/2016.
//
//

import Foundation
import CryptoSwift

struct CKServerRequestAuth {
    
    static let ISO8601DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return dateFormatter
    }()
    
    static let CKRequestKeyIDHeaderKey = "X-Apple-CloudKit-Request-KeyID"
    
    static let CKRequestDateHeaderKey =  "X-Apple-CloudKit-Request-ISO8601Date"
    
    static let CKRequestSignatureHeaderKey = "X-Apple-CloudKit-Request-SignatureV1"
    
    
    let requestDate: String
    
    let signature: String
    
    init?(requestBody: NSData, urlPath: String, privateKeyPath: String) {
        
        self.requestDate = CKServerRequestAuth.ISO8601DateFormatter.string(from: Date())
        
        if let signature = CKServerRequestAuth.signature(requestDate: requestDate,requestBody: requestBody, urlSubpath: urlPath, privateKeyPath: privateKeyPath) {
            
            self.signature = signature
            
        } else {
            return nil
        }
    }
    
    static func sign(data: NSData, privateKeyPath: String) -> NSData? {
        do {
            
            let ecsda = try! MessageDigest("sha256WithRSAEncryption")
            let digestContext =  try! MessageDigestContext(ecsda)
            
            try digestContext.update(data)
            return try digestContext.sign(privateKeyURL: privateKeyPath)
            
        } catch {
            print(error)
            return nil
        }
    }
    
    static func rawPayload(withRequestDate requestDate: String, requestBody: NSData, urlSubpath: String) -> String {
        
        let bodyHash = requestBody.bridge().sha256()
        let hashedBody = bodyHash.base64EncodedString(options: [])
        return "\(requestDate):\(hashedBody):\(urlSubpath)"
    }
    
    static func signature(requestDate: String, requestBody: NSData, urlSubpath: String, privateKeyPath: String) -> String? {
        
        let rawPayloadString = rawPayload(withRequestDate: requestDate, requestBody: requestBody, urlSubpath: urlSubpath)
      
        let requestData = rawPayloadString.data(using: String.Encoding.utf8)!
       
        
        let signedData = sign(data: NSData(data: requestData), privateKeyPath: privateKeyPath)
        
        return signedData?.base64EncodedString(options: [])
    }
    
    static func authenicateServer(forRequest request: URLRequest, withServerToServerKeyAuth auth: CKServerToServerKeyAuth) -> URLRequest? {
        return authenticateServer(forRequest: request, serverKeyID: auth.keyID, privateKeyPath: auth.privateKeyFile)
    }
    
    static func authenticateServer(forRequest request: URLRequest, serverKeyID: String, privateKeyPath: String) -> URLRequest? {
        var request = request
        guard let requestBody = request.httpBody, let path = request.url?.path, let auth = CKServerRequestAuth(requestBody: NSData(data: requestBody), urlPath: path, privateKeyPath: privateKeyPath) else {
            return nil
        }
        
        request.setValue(serverKeyID, forHTTPHeaderField: CKRequestKeyIDHeaderKey)
        request.setValue(auth.requestDate, forHTTPHeaderField: CKRequestDateHeaderKey)
        request.setValue(auth.signature, forHTTPHeaderField: CKRequestSignatureHeaderKey)
        
        
        return request
    }
}

