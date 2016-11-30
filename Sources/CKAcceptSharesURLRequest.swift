//
//  CKAcceptSharesURLRequest.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 16/10/16.
//
//

import Foundation

class CKAcceptSharesURLRequest: CKURLRequest {
    
   // let shareMetadatasToAccept: [CKShareMetadata]
    
    
    init(shortGUIDs: [CKShortGUID]) {
        super.init()
        
        self.path = "accept"
        self.operationType = CKOperationRequestType.records
        
        var parameters: [String: Any] = [:]
        
        parameters["shortGUIDs"] = shortGUIDs.map({ (guid) -> NSDictionary in
            return guid.dictionary.bridge()
        }).bridge()
        
        requestProperties = parameters
        accountInfoProvider = CloudKit.shared.defaultAccount

    }
    
    convenience init(shareMetadatasToAccept: [CKShareMetadata]) {
        
        self.init(shortGUIDs: [])
        
    }
}

