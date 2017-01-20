//
//  CKTokenRegistrationURLRequest.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/1/17.
//
//

import Foundation

class PBCodable {
    func dictionaryRepresentation() -> [String: Any] {
        return [:]
    }
}

class CKTokenRegistrationBody: PBCodable {
    
    let apnsEnv: String
    
    let token: Data
    
    init(apnsEnv: String, token: Data) {
        self.apnsEnv = apnsEnv
        self.token = token
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        return ["apnsEnvironment": apnsEnv, "apnsToken": token.base64EncodedString()]
    }
}

class CKTokenRegistrationURLRequest: CKURLRequest {
    
    var tokenRegistrationBody: CKTokenRegistrationBody?
    
    var hasTokenRegistrationBody: Bool {
        return tokenRegistrationBody != nil
    }
    
    let apsEnvironmentString: String
    
    override var serverType: CKServerType {
        return .device
    }
    
    let token: Data
    
    init(token: Data, apnsEnvironment: String) {
        
        self.token = token
        self.apsEnvironmentString = apnsEnvironment
        
        super.init()
        
        self.operationType = .tokens
        path = "register"
        
        let body = CKTokenRegistrationBody(apnsEnv: apnsEnvironment, token: token)
        requestProperties = body.dictionaryRepresentation()
    }
    
    override var requiresTokenRegistration: Bool {
        return false
    }
    
    
}
