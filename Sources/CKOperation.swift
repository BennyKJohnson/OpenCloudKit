//
//  CKOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 7/07/2016.
//
//

import Foundation

public class CKOperation: Operation {
    
    public var container: CKContainer?

    public var requestUUIDs: [String] = []
    
    var _isFinished: Bool = false
    
    var _isExecuting: Bool = false
    
    var urlSessionTask: URLSessionTask?
    
    override init() {
        super.init()
    }

    public override func start() {
        
        // Check if operation is already cancelled
        if isCancelled {
            isFinished = true
            return
        }
        
        // Perform CKOperation of superclass
        performCKOperation()
        
        // Send out KVO notifications for the executing
        isExecuting = true

    }
    
    public override func main() {
        super.main()
        performCKOperation()
    }
    
    public override func cancel() {
        // Calling Super will update the isCancelled and send KVO notifications
        super.cancel()
        
        // Not sure why cancel is overridden
        urlSessionTask?.cancel()
    }

    func processOperationResult() {
        
    }
    
    func finishOnCallbackQueueWithError(error: NSError) {
    }
    
    func performCKOperation() {}

    override public var isConcurrent: Bool {
        get { return true }
    }
    
    override public var isFinished: Bool {
        get { return _isFinished }
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override public var isExecuting: Bool {
        get { return _isExecuting}
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = isExecuting
            didChangeValue(forKey: "isExecuting")

        }
    }
}

public class CKDatabaseOperation : CKOperation {
    
    public var database: CKDatabase?
    
}

extension CKOperation {
    var databaseURL: String {
        let operationContainer = container ?? CKContainer.defaultContainer()
        return "\(CloudKit.path)/database/\(CloudKit.version)/\(operationContainer.containerIdentifier)/\(CloudKit.shared.environment)/"
    }
}

extension CKDatabaseOperation {
    var operationURL: String {
        
        // Create URL
        let operationDatabase = database?.scope ?? CKDatabaseScope.Public
        let urlForDatabaseOperation = "\(databaseURL)\(operationDatabase)"
        
        return urlForDatabaseOperation
    }
}




