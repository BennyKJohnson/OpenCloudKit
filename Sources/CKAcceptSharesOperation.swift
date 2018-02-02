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
    
    override func finishOnCallbackQueue(error: Error?) {
        self.acceptSharesCompletionBlock?(error)
        
        super.finishOnCallbackQueue(error: error)
    }
    
    func perShare(shareMetadata: CKShareMetadata, acceptedShare: CKShare?, error: Error?){
        callbackQueue.async {
            self.perShareCompletionBlock?(shareMetadata, nil, nil)
        }
    }

    override func performCKOperation() {
        
        let operationURLRequest = CKAcceptSharesURLRequest(shortGUIDs: shortGUIDs)
        
        operationURLRequest.accountInfoProvider = CloudKit.shared.defaultAccount
        
        operationURLRequest.completionBlock = { [weak self] (result) in
            guard let strongSelf = self, !strongSelf.isCancelled else {
                return
            }
            switch result {
            case .success(let dictionary):
                
                // Process Records
                if let resultsDictionary = dictionary["results"] as? [[String: Any]] {
                    // Parse JSON into CKRecords
                    for resultDictionary in resultsDictionary {
                        if let shareMetadata = CKShareMetadata(dictionary: resultDictionary) {
                            strongSelf.perShare(shareMetadata: shareMetadata, acceptedShare: nil, error: nil)
                        }
                    }
                }
                
                strongSelf.finish(error: nil)
                
            case .error(let error):
                strongSelf.finish(error: error.error)
            }
        }
        
        operationURLRequest.performRequest()
    }


    
}
