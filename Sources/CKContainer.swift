//
//  CKContainer.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation


public class CKContainer {
    
    let convenienceOperationQueue = OperationQueue()
    
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
    
    public lazy var sharedCloudDatabase: CKDatabase = {
        return CKDatabase(container: self, scope: .shared)
    }()
    
    var isRegisteredForNotifications: Bool {
        return false
    }

    
    func registerForNotifications() {}
    
    func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void) {
        
        guard let _ = CloudKit.shared.defaultAccount.iCloudAuthToken else {
            completionHandler(.noAccount, nil)
            return
        }
        
        // Verify the account is valid
        completionHandler(.available, nil)
    }
    
    func schedule(convenienceOperation: CKOperation) {
        convenienceOperation.queuePriority = .veryHigh
        convenienceOperation.qualityOfService = .utility
        
        add(convenienceOperation)
    }
    
    public func add(_ operation: CKOperation) {
        if !operation.isKind(of: CKDatabaseOperation.self) {
            operation.container = self
            convenienceOperationQueue.addOperation(operation)
        } else {
            fatalError("CKDatabaseOperations must be submitted to a CKDatabase")
        }
    }

}
