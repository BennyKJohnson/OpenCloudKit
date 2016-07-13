//
//  CKContainer.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation

public class CKContainer {
    
    let containerIdentifier: String
    
    init(containerIdentifier: String) {
        self.containerIdentifier = containerIdentifier
    }
    
    class func defaultContainer() -> CKContainer {
        // Get Default Container
        return CKContainer(containerIdentifier: CloudKit.shared.containers.first!.containerIdentifier)
    }
    
    lazy var publicCloudDatabase: CKDatabase = {
        return CKDatabase(container: self, scope: .Public)
    }()
    
    lazy var privateCloudDatabase: CKDatabase = {
        return CKDatabase(container: self, scope: .Private)
    }()
}
