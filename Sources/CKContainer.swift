//
//  CKContainer.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation


public class CKContainer {
    
    public let containerIdentifier: String
    
    public init(containerIdentifier: String) {
        self.containerIdentifier = containerIdentifier
    }
    
    public class func `default`() -> CKContainer {
        // Get Default Container
        return CKContainer(containerIdentifier: CloudKit.shared.containers.first!.containerIdentifier)
    }
    
    public lazy var publicCloudDatabase: CKDatabase = {
        return CKDatabase(container: self, scope: .public)
    }()
    
    public lazy var privateCloudDatabase: CKDatabase = {
        return CKDatabase(container: self, scope: .private)
    }()
    
    
    var isRegisteredForNotifications: Bool {
        return false
    }
}
