//
//  CKTokenInfo.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 15/07/2016.
//
//

import Foundation

struct CKTokenInfo {
    let apnsEnvironment: CKEnvironment
    let apnsToken: String
    let webcourierURL: String
}

extension CKTokenInfo {
    
    init?(dictionary: [String: AnyObject]) {
        guard let apnsEnvironment = CKEnvironment(rawValue: dictionary["apnsEnvironment"] as? String ?? ""),
        apnsToken = dictionary["apnsToken"] as? String, webcourierURL = dictionary["webcourierURL"] as? String else {
            return nil
        }
        
        self.apnsEnvironment = apnsEnvironment
        self.apnsToken = apnsToken
        self.webcourierURL = webcourierURL
    
    }
}
