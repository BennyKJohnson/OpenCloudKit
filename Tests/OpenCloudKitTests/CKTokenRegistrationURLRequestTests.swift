//
//  CKCreateTokenTests.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/1/17.
//
//

import XCTest
import Foundation
@testable import OpenCloudKit

class CKCreateTokensTests: XCTestCase {
    
    
    let containerID = "iCloud.benjamin.CloudTest"
    let environment: CKEnvironment = .development
    let apiToken = "f91d18c0fdef4846b3f4d5fff48c3e1a915beaf5098733c8eaa2b1132d6e5445"
    let databaseScope = CKDatabaseScope.public
    
    override func setUp() {
        super.setUp()
        
        let containerConfig = CKContainerConfig(containerIdentifier: containerID, environment: environment, apiTokenAuth: apiToken)
        CloudKit.shared.configure(with: CKConfig(container: containerConfig))
    }
    
  
    
    func testCreateTokenOperation() {
        CloudKit.shared.verbose = true
        let exp = expectation(description: "Create Token")
        let operation = CKTokenCreateOperation(apnsEnvironment: .development)
        operation.createTokenCompletionBlock = {
            (info, error) in
            
            if let info = info {
                print(info)
            } else if let error = error {
                print(error)
            }
            exp.fulfill()

        }
        
        operation.start()
        
        waitForExpectations(timeout: 10.0, handler: nil)
        
    }
}
