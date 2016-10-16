//
//  CKContainerInfo.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 25/07/2016.
//
//

import Foundation

struct CKContainerInfo {
    
    let environment: CKEnvironment
    
    let containerID: String
    
    var publicCloudDBURL: URL {
        let baseURL = "\(CKServerInfo.path)/database/\(CKServerInfo.version)/\(containerID)/\(environment)/public"
        return URL(string: baseURL)!
    }
    
    func databaseURL(for scope: CKDatabaseScope) -> URL {
        let baseURL = "\(CKServerInfo.path)/database/\(CKServerInfo.version)/\(containerID)/\(environment)/\(scope)"
        return URL(string: baseURL)!
    }
    
    
    init(containerID: String, environment: CKEnvironment) {
        self.containerID = containerID
        self.environment = environment
    }
}
