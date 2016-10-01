//
//  CKOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 7/07/2016.
//
//

import Foundation

enum CKOperationState: Int {
    case initialized
    case pending
    case ready
    case executing
    case finished
}

public class CKOperation: Operation {
    
    public var container: CKContainer?

    public var requestUUIDs: [String] = []
    
    var _isFinished: Bool = false
    
    var _isExecuting: Bool = false
    
    var urlSessionTask: URLSessionTask?
    
    var request: CKURLRequest?
    
    var childOperations: [CKOperation] = []
    
    var operationID: String
    
    var cloudKitMetrics: CKOperationMetrics?
    
    weak var parentOperation: CKOperation?
    
    private var state: CKOperationState = .initialized
    
    override init() {
        operationID = NSUUID().uuidString
        super.init()
    }
    
    var operationContainer: CKContainer {
        return container ?? CKContainer.defaultContainer()
    }

    public override func start() {
        
        super.start()
        
        // Check if operation is already cancelled
        if isCancelled {
            state = .finished
            return
        }
 
        
        // Send out KVO notifications for the executing
        state = .executing

    }
    
    func execute() {
        
    }
    
    func addAndRun(childOperation: CKOperation) {
        childOperations.append(childOperation)
        childOperation.start()
    }
    
    func configure(request: CKURLRequest) {
        // Configure Request
    }
    
    public override func main() {

        if !isCancelled {
            performCKOperation()

        } else {
            finish()
        }
    }
    
    public override func cancel() {
        // Calling Super will update the isCancelled and send KVO notifications
        super.cancel()
        
        // Not sure why cancel is overridden
        urlSessionTask?.cancel()
    }

    func processOperationResult() {
        
    }
    
    func finishOnCallbackQueueWithError(error: Error) {
    }
    
    func performCKOperation() {}

    final func finish(error:[NSError] = []) {
        state = .finished
    }
    
  
    override public var isFinished: Bool {
       return state == .finished
    }
    
    override public var isExecuting: Bool {
        return state == .executing
    }
    
    override public var isReady: Bool {
        switch state {
        case .initialized:
            return true
        case .ready:
            return super.isReady || isCancelled
            
        default:
            return false
        } // MARK: State Management
    }
    /*
    public var isConcurrent: Bool {
        get { return true }
    }
    */
}

public class CKDatabaseOperation : CKOperation {
    
    public var database: CKDatabase?
    
}

extension CKOperation {
    var databaseURL: String {
        let operationContainer = container ?? CKContainer.defaultContainer()
        return "\(CKServerInfo.path)/database/\(CKServerInfo.version)/\(operationContainer.containerIdentifier)/\(CloudKit.shared.environment)/"
    }
}

extension CKDatabaseOperation {
    var operationURL: String {
        
        // Create URL
        let operationDatabase = database?.scope ?? CKDatabaseScope.public
        let urlForDatabaseOperation = "\(databaseURL)\(operationDatabase)"
        
        return urlForDatabaseOperation
    }
}




