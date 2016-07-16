//
//  CKRegisterTokenOperation.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 15/07/2016.
//
//

import Foundation

public class CKRegisterTokenOperation : CKOperation {
    
    let apnsEnvironment: CKEnvironment
    
    var apnsToken: String?
    
    public init(apnsEnvironment: CKEnvironment) {
        self.apnsEnvironment = apnsEnvironment
        super.init()
    }
    
    public init(apnsEnvironment:CKEnvironment, apnsToken: String) {
        self.apnsEnvironment = apnsEnvironment
        super.init()
        self.apnsToken = apnsToken
    }
    
    override func finishOnCallbackQueueWithError(error: NSError) {
        createTokenCompletionBlock?(nil, error)
    }
    
    var createTokenCompletionBlock: ((CKTokenInfo?, NSError?) -> Void)?
    
    override func performCKOperation() {
        let url: String
        var request: [String: AnyObject] = ["apnsEnvironment": apnsEnvironment.rawValue]
        if let apnsToken = apnsToken {
            url = "\(databaseURL)/tokens/register"
            request["apnsToken"] = apnsToken
        } else {
            url = "\(databaseURL)/tokens/create"

        }
        
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url, parameters: request) { (dictionary, error) in
            
            if self.isCancelled {
                // Send Cancelled Error to CompletionBlock
                let cancelError = NSError(domain: CKErrorDomain, code: CKErrorCode.OperationCancelled.rawValue, userInfo: nil)
                self.finishOnCallbackQueueWithError(error: cancelError)
            }
            let tokenInfo: CKTokenInfo?
            if let error = error {
                tokenInfo = nil
                self.finishOnCallbackQueueWithError(error: error)
                return
            } else if let dictionary = dictionary {
                tokenInfo = CKTokenInfo(dictionary: dictionary)
            } else {
                tokenInfo = nil
            }
            
            self.createTokenCompletionBlock?(tokenInfo, error)
            
            // Mark operation as complete
            self.isExecuting = false
            self.isFinished = true
        }
    }
}
