//
//  CKServerType.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/1/17.
//
//

import Foundation

enum CKServerType: String {
    
    case database = "CKDatabaseService"
    
    case share = "CKShareService"
    
    case device = "CKDeviceService"
    
    case codeService = "CKCodeService"
    
    var urlComponent: String {
        switch self {
        case .database:
            return "database"
        case .share:
            return "database"
        case .device:
            return "device"
        default:
            fatalError()
        }
    }
    
}
