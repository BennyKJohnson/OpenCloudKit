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
    
    var tokenInfo: CKPushTokenInfo?
    
    public var registerTokenCompletionBlock: ((CKPushTokenInfo?, Error?) -> Void)?
    
    init(apnsEnvironment:CKEnvironment, apnsToken: Data) {
        
        self.apnsEnvironment = apnsEnvironment
        
        self.apnsToken = apnsToken

        super.init()
        
    }
    
    override func finishOnCallbackQueue(error: Error?) {
        registerTokenCompletionBlock?(tokenInfo, error)
        
        super.finishOnCallbackQueue(error: error)
    }
    
    override func performCKOperation() {
        
        let request = CKTokenRegistrationURLRequest(token: apnsToken, apnsEnvironment: "\(apnsEnvironment)")
        request.completionBlock = { (result) in
            if(self.isCancelled){
                return
            }
            switch result {
            case .success(let dictionary):
                self.tokenInfo = CKPushTokenInfo(dictionaryRepresentation: dictionary)
                print(dictionary)
                self.finish(error: nil)
            case .error(let error):
                self.finish(error: error.error)
            }
        }
        
        request.performRequest()
    }
}
