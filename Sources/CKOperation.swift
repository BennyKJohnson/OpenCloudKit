//
//  CKOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 7/07/2016.
//
//

import Foundation
import Dispatch

public class CKOperation: Operation {
    
    public var container: CKContainer?

    public var requestUUIDs: [String] = []
    
    private var _finished: Bool = false
    
    private var _executing: Bool = false
    
    var urlSessionTask: URLSessionTask?
    
    var request: CKURLRequest?
    
    var childOperations: [CKOperation] = []
    
    var operationID: String
    
    var cloudKitMetrics: CKOperationMetrics?
    
    weak var parentOperation: CKOperation?
    
    private var error: Error?
    
    private let callbackQueue: DispatchQueue = DispatchQueue(label: "queuename")

    override init() {
        if type(of: self) == CKOperation.self {
            fatalError("You must use a concrete subclass of CKOperation")
        }
        
        operationID = NSUUID().uuidString
        super.init()
    }
    
    var operationContainer: CKContainer {
        return container ?? CKContainer.default()
    }

    open override func start() {
        
        // Check if operation is already cancelled
        if isCancelled && isFinished {
            print("Not starting already cancelled operation \(self)")
            return
        }
 
        if(isExecuting || isFinished){
            // NSException not available on Linux, fatalError is the alternative.
            // NSException.raise(NSExceptionName.invalidArgumentException, format: "You can't restart an executing or finished CKOperation: %@", arguments:getVaList([self]))
            fatalError("You can't restart an executing or finished CKOperation")
        }
        
        // Send out KVO notifications for the executing
        isExecuting = true

        if(isCancelled){
            
            // Must move the operation to the finished state if it is cancelled before it started.
            let error = CKPrettyError(code: CKErrorCode.OperationCancelled, description: "Operation \(self) was cancelled before it started")
            
            finish(error: error)
            
            return;
        }
        
        main()
    }
    
    func addAndRun(childOperation: CKOperation) {
        childOperations.append(childOperation)
        childOperation.start()
    }
    
    func configure(request: CKURLRequest) {
        // Configure Request
    }
    
    open override func main() {

        if !isCancelled {
            do {
                try CKOperationShouldRun()
                performCKOperation()
            } catch {
                finish(error: error)
            }
        }
    }
    
    func CKOperationShouldRun() throws {
        // default implementation does nothing.
    }
    
    open override func cancel() {
        // Calling Super will update the isCancelled and send KVO notifications
        super.cancel()
        
        let error = CKPrettyError(code: CKErrorCode.OperationCancelled, description: "Operation \(self) was cancelled")
        
        finish(error: error)
        
        urlSessionTask?.cancel()
    }

    func processOperationResult() {
        
    }
    
    func finishInternalOnCallbackQueue(error: Error?){
        var error = error
        if(!isExecuting){
            return
        }
        if(error == nil){
            if(isCancelled){
                error = CKPrettyError(code: CKErrorCode.OperationCancelled, description: "Operation \(self) was cancelled")
            }
        }
        // not sure why this is retained yet
        if(self.error == nil){
            self.error = error;
        }
        if(!isFinished){
            finishOnCallbackQueue(error: error)
            return
        }
        
        print("The operation operation \(self) didn't start or is already finished")
    }
    

    // overrides require super
    func finishOnCallbackQueue(error: Error?) {
        assert(!isFinished, "Operation was already marked as finished")
        isExecuting = false
        isFinished = true
    }
    
    func performCKOperation() {
        fatalError("performCKOperation should be override by \(self)")
    }

    func finish(error: Error?) {
        callbackQueue.async {
            self.finishInternalOnCallbackQueue(error: error)
        }
    }
    
    override public var isFinished : Bool {
        get { return _finished }
        set {
            guard _finished != newValue else { return }
            // Linux doesn't support KVO
            #if os(Linux)
                _finished = newValue
            #else
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            #endif

        }
    }
    
    override public var isExecuting : Bool {
        get { return _executing }
        set {
            guard _executing != newValue else { return }
            
            // Linux doesn't support KVO
            #if os(Linux)
                _executing = newValue
            #else
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            #endif
        }
    }
    
    override public var isAsynchronous: Bool {
        get { return true }
    }
}

public class CKDatabaseOperation : CKOperation {
    
    public var database: CKDatabase?
    
}

extension CKOperation {
    var databaseURL: String {
        let operationContainer = container ?? CKContainer.default()
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




