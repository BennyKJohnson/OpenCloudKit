//
//  CKDiscoverAllUserIdentitiesOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 14/07/2016.
//
//

import Foundation

public class CKDiscoverAllUserIdentitiesOperation : CKOperation {
    
    var discoveredIdentities: [CKUserIdentity] = []
    
    public override init() {
        super.init()
    }
    
    
    public var userIdentityDiscoveredBlock: ((CKUserIdentity) -> Swift.Void)?
    
    public var discoverAllUserIdentitiesCompletionBlock: ((Error?) -> Swift.Void)?
    
    override func finishOnCallbackQueue(error: Error?) {
        
        self.discoverAllUserIdentitiesCompletionBlock?(error)
        
        super.finishOnCallbackQueue(error: error)
    }
    
    func discovered(userIdentity: CKUserIdentity){
        callbackQueue.async {
            self.userIdentityDiscoveredBlock?(userIdentity)
        }
    }
    
    override func performCKOperation() {
        
        let url = "\(databaseURL)/public/users/discover"
      
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url) { [weak self] (dictionary, error) in
            
            guard self != nil, !self!.isCancelled else {
                return
            }
            
            var returnError = error
            defer {
                self?.finish(error: returnError)
            }
            
            guard let dictionary = dictionary,
                let userDictionaries = dictionary["users"] as? [[String: Any]],
                error == nil else {
                    return
            }
            
            // Process Records
            // Parse JSON into CKRecords
            for userDictionary in userDictionaries {
                
                if let userIdentity = CKUserIdentity(dictionary: userDictionary) {
                    self?.discoveredIdentities.append(userIdentity)
                    
                    // Call discovered callback
                    self?.discovered(userIdentity: userIdentity)
                    
                } else {
                    
                    // Create Error
                    returnError = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: "Failed to parse record from server"])
                    return
                }
            }
        }
    }
}
