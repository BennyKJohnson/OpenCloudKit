//
//  CKErrorCode.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 7/07/2016.
//
//

import Foundation

let CKErrorDomain: String = "CKErrorDomain"

enum CKErrorCode : Int {
    case InternalError
    case PartialFailure
    case NetworkUnavailable
    case NetworkFailure
    case BadContainer
    case ServiceUnavailable
    case RequestRateLimited
    case MissingEntitlement
    case NotAuthenticated
    case PermissionFailure
    case UnknownItem
    case InvalidArguments
    case ResultsTruncated
    case ServerRecordChanged
    case ServerRejectedRequest
    case AssetFileNotFound
    case AssetFileModified
    case IncompatibleVersion
    case ConstraintViolation
    case OperationCancelled
    case ChangeTokenExpired
    case BatchRequestFailed
    case ZoneBusy
    case BadDatabase
    case QuotaExceeded
    case ZoneNotFound
    case LimitExceeded
    case UserDeletedZone
    
}

extension CKErrorCode {
    static func errorCode(serverError: String) -> CKErrorCode? {
        
        switch(serverError) {
        case "ACCESS_DENIED":
            return CKErrorCode.NotAuthenticated
        case "ATOMIC_ERROR":
            return CKErrorCode.BatchRequestFailed
        case "AUTHENTICATION_FAILED":
            return CKErrorCode.NotAuthenticated
        case "AUTHENTICATION_REQUIRED":
            return CKErrorCode.PermissionFailure
        case "BAD_REQUEST":
            return CKErrorCode.ServerRejectedRequest
        case "CONFLICT":
            return CKErrorCode.ChangeTokenExpired
        case "EXISTS":
            return CKErrorCode.ConstraintViolation
        case "INTERNAL_ERROR":
            return CKErrorCode.InternalError
        case "NOT_FOUND":
            return CKErrorCode.UnknownItem
        case "QUOTA_EXCEEDED":
            return CKErrorCode.QuotaExceeded
        case "THROTTLED":
            return CKErrorCode.RequestRateLimited
        case "TRY_AGAIN_LATER":
            return CKErrorCode.InternalError
        case "VALIDATING_REFERENCE_ERROR":
            return CKErrorCode.ConstraintViolation
        case "ZONE_NOT_FOUND":
            return CKErrorCode.ZoneNotFound
        default:
            fatalError("Unknown  Server Error: \(serverError)")
        }
    }

}
