//
//  CKShareParticipant.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 16/10/16.
//
//

public enum CKShareParticipantAcceptanceStatus : Int {
    
    
    case unknown
    
    case pending
    
    case accepted
    
    case removed
}

public enum CKShareParticipantPermission : Int {
    
    
    case unknown
    
    case none
    
    case readOnly
    
    case readWrite
}

public enum CKShareParticipantType : Int {
    
    
    case unknown
    
    case owner
    
    case privateUser
    
    case publicUser
    
    init?(string: String) {
        switch string {
        case "OWNER":
            self = .owner
        case "USER":
            self = .privateUser
        case "PUBLIC_USER":
            self = .publicUser
        case "UNKNOWN":
            self = .unknown
        default:
            fatalError("Unknown type \(string)")
        }
    }
}

open class CKShareParticipant  {
    
    open var userIdentity: CKUserIdentity
    
    
    /* The default participant type is CKShareParticipantTypePrivateUser. */
    open var type: CKShareParticipantType = .privateUser
    
    open var acceptanceStatus: CKShareParticipantAcceptanceStatus = .unknown
    
    /* The default permission for a new participant is CKShareParticipantPermissionReadOnly. */
    open var permission: CKShareParticipantPermission = .readOnly
    
    init(userIdentity: CKUserIdentity) {
        self.userIdentity = userIdentity
    }
}
