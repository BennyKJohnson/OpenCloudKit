//
//  CKCreateTokenTests.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/1/17.
//
//

import XCTest
@testable import OpenCloudKit
import Foundation

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
    
    func testCreateTokenURL() {
        let request = CKTokenCreateURLRequest(apnsEnvironment: .development)
        let url = URLComponents(url: request.url, resolvingAgainstBaseURL: false)!
        print(request.url)
        XCTAssertEqual(url.path, "/device/\(CKServerInfo.version)/\(containerID)/\(environment)/tokens/create")
    }
    
    func testRegisterTokenURL() {
        let request = CKTokenRegistrationURLRequest(token: Data(), apnsEnvironment: "\(environment)")
        let url = URLComponents(url: request.url, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(url.path, "/device/\(CKServerInfo.version)/\(containerID)/\(environment)/tokens/register")
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
