//
//  CKOperationMetrics.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 26/07/2016.
//
//

import Foundation

protocol CKURLRequestMetricsDelegate {
    func requestDidFinish(withMetrics metrics:CKOperationMetrics)
}

struct CKOperationMetrics {
    
    var bytesDownloaded: UInt = 0
    
    var bytesUploaded: UInt = 0
    
    var duration: TimeInterval = 0
    
    var startDate: Date
    
}
