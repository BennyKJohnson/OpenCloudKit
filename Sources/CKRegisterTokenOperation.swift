//
//  CKRegisterTokenOperation.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 15/07/2016.
//
//

import Foundation

class CKRegisterTokenOperation : CKOperation {
    
    let apnsEnvironment: CKEnvironment
    
    let apnsToken: Data
    
    init(apnsEnvironment:CKEnvironment, apnsToken: Data) {
        
        self.apnsEnvironment = apnsEnvironment
        
        self.apnsToken = apnsToken

        super.init()
        
    }
    
    override func finishOnCallbackQueueWithError(error: Error) {
        registerTokenCompletionBlock?(nil,error)
    }
    
    public var registerTokenCompletionBlock: ((CKPushTokenInfo?, Error?) -> Void)?
    
    override func performCKOperation() {
        
        let request = CKTokenRegistrationURLRequest(token: apnsToken, apnsEnvironment: "\(apnsEnvironment)")
        request.completionBlock = { (result) in
            switch result {
            case .success(let dictionary):
                let tokenInfo = CKPushTokenInfo(dictionaryRepresentation: dictionary)
                
                print(dictionary)
                self.registerTokenCompletionBlock?(tokenInfo, nil)
            case .error(let error):
                self.registerTokenCompletionBlock?(nil, error.error)
            }
            
            self.finish()
        }
        
        request.performRequest()
    }
}
