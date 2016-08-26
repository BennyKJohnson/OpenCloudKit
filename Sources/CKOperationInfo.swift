//
//  CKOperationInfo.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 29/07/2016.
//
//

import Foundation

class CKOperationInfo {
    
}

class CKDatabaseOperationInfo: CKOperationInfo {
    let databaseScope: CKDatabaseScope
    
    init(databaseScope: CKDatabaseScope) {
        self.databaseScope = databaseScope
        super.init()
    }
    
}

extension CKOperationInfo: CKCodable {
    var dictionary: [String : Any] {
        return [:]
    }
}

