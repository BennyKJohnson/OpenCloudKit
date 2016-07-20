//
//  CKFetchErrorDictionary.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 15/07/2016.
//
//

import Foundation

protocol CKFetchErrorDictionaryIdentifier {
    init?(dictionary: [String: AnyObject])
    
    static var identifierKey: String { get }
}

extension CKRecordZoneID: CKFetchErrorDictionaryIdentifier {
    
    @nonobjc static let identifierKey = "zoneID"
    
}

struct CKFetchErrorDictionary<T: CKFetchErrorDictionaryIdentifier> {
    
    let identifier: T
    let reason: String
    let serverErrorCode: String
    let retryAfter: NSNumber?
    let redirectURL: String?
    
    init?(dictionary: [String: AnyObject]) {
        
        guard let identifier = T(dictionary: dictionary[T.identifierKey] as? [String: AnyObject] ?? [:]),
            reason = dictionary[CKRecordFetchErrorDictionary.reasonKey] as? String,
            serverErrorCode = dictionary[CKRecordFetchErrorDictionary.serverErrorCodeKey] as? String
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
        var userInfo: [String: AnyObject] = [NSLocalizedDescriptionKey: reason.bridge(), "serverErrorCode": serverErrorCode]
        if let redirectURL = redirectURL {
            userInfo[CKErrorRedirectURLKey] = redirectURL.bridge()
        }
        if let retryAfter = retryAfter {
            userInfo[CKErrorRetryAfterKey] = retryAfter
        }
        
        return NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: userInfo)
        
    }
}
