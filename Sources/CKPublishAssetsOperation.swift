//
//  CKPublishAssetsOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 16/07/2016.
//
//

import Foundation

public class CKPublishAssetsOperation : CKOperation {
    
    let fileNamesByAssetFieldNames: [String: String] = [:]
    
    var assets: [CKAsset] = []
    
    public var assetPublishedBlock: ((CKAsset?, Error?) -> Void)?

    override func finishOnCallbackQueue(error: Error?) {
        if(error == nil){
            // build partial error
        }
        
        // call assets completion block
        
        super.finishOnCallbackQueue(error: error)
    }
    
    
    override func performCKOperation() {
       //self.finish(error: error or nil)
    }
    
    init(assets: [CKAsset]) {
        self.assets = assets
        
    }
    
}

