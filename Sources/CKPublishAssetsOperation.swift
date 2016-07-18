//
//  CKPublishAssetsOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 16/07/2016.
//
//

import Foundation
/*
public class CKPublishAssetsOperation : CKOperation {
    
    let fileNamesByAssetFieldNames: [String: String]
    
    let
    
    override func finishOnCallbackQueueWithError(error: NSError) {
        registerTokenCompletionBlock?(nil, error)
    }
    
    public var registerTokenCompletionBlock: ((CKTokenInfo?, NSError?) -> Void)?
    
    override func performCKOperation() {
        let url: String
        var request: [String: AnyObject] = ["apnsEnvironment": apnsEnvironment.rawValue]
        if let apnsToken = apnsToken {
            url = "\(databaseURL)/tokens/register"
            request["apnsToken"] = apnsToken
        } else {
            url = "\(databaseURL)/tokens/create"
        }
        
        print(url)
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
            
            self.registerTokenCompletionBlock?(tokenInfo, error)
            
            // Mark operation as complete
            self.isExecuting = false
            self.isFinished = true
        }
    }
}
 */
