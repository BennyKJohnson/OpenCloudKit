//
//  CKRequest.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/1/17.
//
//

import Foundation

struct CKRequestOptions {
    
    var serverType: String?
    
    init(serverType: String) {
        self.serverType = serverType
    }
    
    init() {}
    
}

class CKRequest {
    
    static func options() -> CKRequestOptions {
        return CKRequestOptions()
    }

}
