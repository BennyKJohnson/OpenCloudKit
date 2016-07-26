//
//  CKTokenInfo.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 15/07/2016.
//
//

import Foundation

public struct CKTokenInfo {
    public let apnsEnvironment: CKEnvironment
    public let apnsToken: String
    public let webcourierURL: String
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
