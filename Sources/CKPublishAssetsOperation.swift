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

    override func finishOnCallbackQueueWithError(error: Error) {

    }
    
    
    override func performCKOperation() {
       
        
   
        
        
    }
    
    init(assets: [CKAsset]) {
        self.assets = assets
        
    }
}

