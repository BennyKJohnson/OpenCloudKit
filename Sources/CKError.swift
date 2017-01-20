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
    case TooManyParticipants
    case AlreadyShared
    case ReferenceViolation
    case ManagedAccountRestricted
    case ParticipantMayNeedVerification
    
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

extension CKErrorCode: CustomStringConvertible {
    var description: String {
        switch self {
        case .InternalError:
            return "Internal Error"
        case .PartialFailure:
            return "Partial Failure"
        case .NetworkUnavailable:
            return "Network Unavailable"
        case .NetworkFailure:
            return "Network Failure"
        case .BadContainer:
            return "Bad Container"
        case .ServiceUnavailable:
            return "Service Unavailable"
        case .RequestRateLimited:
            return "Request Rate Limited"
        case .MissingEntitlement:
            return "Missing Entitlement"
        case .NotAuthenticated:
            return "Not Authenticated"
        case .PermissionFailure:
            return "Permission Failure"
        case .UnknownItem:
            return "Unknown Item"
        case .InvalidArguments:
            return "Invalid Arguments"
        case .ResultsTruncated:
            return "Results Truncated"
        case .ServerRecordChanged:
            return "Server Record Changed"
        case .ServerRejectedRequest:
            return "Server Rejected Request"
        case .AssetFileNotFound:
            return "Asset File Not Found"
        case .AssetFileModified:
            return "Asset File Modified"
        case .IncompatibleVersion:
            return "Incompatible Version"
        case .ConstraintViolation:
            return "Constraint Violation"
        case .OperationCancelled:
            return "Operation Cancelled"
        case .ChangeTokenExpired:
            return "Change Token Expired"
        case .BatchRequestFailed:
            return "Batch Request Failed"
        case .ZoneBusy:
            return "Zone Busy"
        case .BadDatabase:
            return "Invalid Database For Operation"
        case .QuotaExceeded:
            return "Quota Exceeded"
        case .ZoneNotFound:
            return "Zone Not Found"
        case .LimitExceeded:
            return "Limit Exceeded"
        case .UserDeletedZone:
            return "User Deleted Zone"
        case .TooManyParticipants:
            return "Too Many Participants"
        case .AlreadyShared:
            return "Already Shared"
        case .ReferenceViolation:
            return "Reference Violation"
        case .ManagedAccountRestricted:
            return "Managed Account Restricted"
        case .ParticipantMayNeedVerification:
            return "Participant May Need Verification"
        }
    }

}
