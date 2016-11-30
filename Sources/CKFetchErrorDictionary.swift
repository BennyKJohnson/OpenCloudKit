//
//  CKFetchErrorDictionary.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 15/07/2016.
//
//

import Foundation

protocol CKFetchErrorDictionaryIdentifier {
    init?(dictionary: [String: Any])
    
    static var identifierKey: String { get }
}

extension CKRecordZoneID: CKFetchErrorDictionaryIdentifier {
    
    @nonobjc static let identifierKey = "zoneID"
    
}

// TODO: Fix error handling
struct CKErrorDictionary {
    
    let reason: String
    let serverErrorCode: String
    let retryAfter: NSNumber?
    let redirectURL: String?
    let uuid: String
    
    init?(dictionary: [String: Any]) {
        
        guard
            let uuid = dictionary["uuid"] as? String,
            let reason = dictionary[CKRecordFetchErrorDictionary.reasonKey] as? String,
            let serverErrorCode = dictionary[CKRecordFetchErrorDictionary.serverErrorCodeKey] as? String
            else {
                return nil
        }
        
        self.uuid = uuid
        self.reason = reason
        self.serverErrorCode = serverErrorCode
        
        self.retryAfter = (dictionary[CKRecordFetchErrorDictionary.retryAfterKey] as? NSNumber)
        self.redirectURL = dictionary[CKRecordFetchErrorDictionary.redirectURLKey] as? String
        
        
    }
    
    func error() -> NSError {
        
        let errorCode = CKErrorCode.errorCode(serverError: serverErrorCode)!
        
        var userInfo: NSErrorUserInfoType = [NSLocalizedDescriptionKey: reason.bridge() as Any, "serverErrorCode": serverErrorCode.bridge() as Any]
        if let redirectURL = redirectURL {
            userInfo[CKErrorRedirectURLKey] = redirectURL.bridge()
        }
        if let retryAfter = retryAfter {
            userInfo[CKErrorRetryAfterKey] = retryAfter as NSNumber
        }
        
        return NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: userInfo)
        
    }
}

struct CKFetchErrorDictionary<T: CKFetchErrorDictionaryIdentifier> {
    
    let identifier: T
    let reason: String
    let serverErrorCode: String
    let retryAfter: NSNumber?
    let redirectURL: String?
    
    init?(dictionary: [String: Any]) {
        
        guard
            let identifier = T(dictionary: dictionary[T.identifierKey] as? [String: Any] ?? [:]),
            let reason = dictionary[CKRecordFetchErrorDictionary.reasonKey] as? String,
            let serverErrorCode = dictionary[CKRecordFetchErrorDictionary.serverErrorCodeKey] as? String
            else {
                return nil
        }
        
        self.identifier = identifier
        self.reason = reason
        self.serverErrorCode = serverErrorCode
        
        self.retryAfter = (dictionary[CKRecordFetchErrorDictionary.retryAfterKey] as? NSNumber)
        self.redirectURL = dictionary[CKRecordFetchErrorDictionary.redirectURLKey] as? String
        
        
    }
    
    func error() -> NSError {
        
        let errorCode = CKErrorCode.errorCode(serverError: serverErrorCode)!
        
        var userInfo: NSErrorUserInfoType = [NSLocalizedDescriptionKey: reason.bridge() as Any, "serverErrorCode": serverErrorCode.bridge() as Any]
        if let redirectURL = redirectURL {
            userInfo[CKErrorRedirectURLKey] = redirectURL.bridge()
        }
        if let retryAfter = retryAfter {
            userInfo[CKErrorRetryAfterKey] = retryAfter as NSNumber
        }
        
        return NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: userInfo)
        
    }
}
