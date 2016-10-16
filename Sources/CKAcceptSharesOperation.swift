//
//  CKAcceptSharesOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 16/10/16.
//
//

import Foundation

public class CKAcceptSharesOperation: CKOperation {
    
    var shortGUIDs: [CKShortGUID]
    
    public var acceptSharesCompletionBlock: ((Error?) -> Void)?
    
    public var perShareCompletionBlock: ((CKShareMetadata, CKShare?, Error?) -> Void)?
    
    public override init() {
        shortGUIDs = []
        super.init()
    }
    
    public convenience init(shortGUIDs: [CKShortGUID]) {
        self.init()
        self.shortGUIDs = shortGUIDs
    }
    
    override func performCKOperation() {
        
        let operationURLRequest = CKAcceptSharesURLRequest(shortGUIDs: shortGUIDs)
        
        operationURLRequest.accountInfoProvider = CloudKit.shared.defaultAccount
        
        operationURLRequest.completionBlock = { (result) in
            
            switch result {
            case .success(let dictionary):
                
                // Process Records
                if let resultsDictionary = dictionary["results"] as? [[String: AnyObject]] {
                    // Parse JSON into CKRecords
                    for resultDictionary in resultsDictionary {
                        if let shareMetadata = CKShareMetadata(dictionary: resultDictionary) {
                            self.perShareCompletionBlock?(shareMetadata, nil, nil)
                        }
                        
                    }
                }
                
                self.acceptSharesCompletionBlock?(nil)
                
            case .error(let error):
                self.acceptSharesCompletionBlock?(error.error)
            }
        }
        
        operationURLRequest.performRequest()
    }

    
}
