//
//  CKConfigTests.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 14/07/2016.
//
//

import XCTest
@testable import OpenCloudKit

class CKConfigTests: XCTestCase {
    
    func pathForTests() -> String {
        let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
        return parent
    }
    
    static var allTests : [(String, (CKConfigTests) -> () throws -> Void)] {
        return [
            ("testInitializingContainerConfigWithToken", testInitializingContainerConfigWithToken),
            ("testServerToServerAuthKeyEqualable", testServerToServerAuthKeyEqualable),
            ("testInitializingContainerConfigWithServerToServerAuthKey", testInitializingContainerConfigWithServerToServerAuthKey),
            ("testInitializingContainerConfigWithDictionary", testInitializingContainerConfigWithDictionary),
            ("testInitializingConfigWithFile", testInitializingConfigWithFile)
        ]
    }
    
    
    func testInitializingContainerConfigWithToken() {
        let containerID = "CONTAINER_ID"
        let apiToken = "API_TOKEN"
        let environment = CKEnvironment.development
        
        let containerConfig = CKContainerConfig(containerIdentifier: containerID, environment: environment, apiTokenAuth: apiToken)
        
        XCTAssertEqual(containerConfig.containerIdentifier, containerConfig.containerIdentifier)
        XCTAssertEqual(containerConfig.environment, environment)
        XCTAssertEqual(containerConfig.apnsEnvironment, environment)
        XCTAssertEqual(containerConfig.apiTokenAuth, apiToken)
        XCTAssertNil(containerConfig.serverToServerKeyAuth)
        
    }
    
    func testServerToServerAuthKeyEqualable() {
        let first = CKServerToServerKeyAuth(keyID: "KEY_ID", privateKeyFile: "eckey.pem", privateKeyPassPhrase: nil)
        let second = CKServerToServerKeyAuth(keyID: "KEY_ID", privateKeyFile: "eckey.pem", privateKeyPassPhrase: nil)
        let third = CKServerToServerKeyAuth(keyID: "abc123", privateKeyFile: "eckey.pem", privateKeyPassPhrase: "my pass phrase")
        
        XCTAssert(first == second)
        XCTAssert(second != third)
    }
    
    func testInitializingContainerConfigWithServerToServerAuthKey() {
        let containerID = "CONTAINER_ID"
        let environment = CKEnvironment.development
        let apnsEnvironment = CKEnvironment.production
        
        let serverToServerKeyAuth = CKServerToServerKeyAuth(keyID: "KEY_ID", privateKeyFile: "eckey.pem", privateKeyPassPhrase: nil)
        
        let containerConfig = CKContainerConfig(containerIdentifier: containerID, environment: environment, serverToServerKeyAuth: serverToServerKeyAuth, apnsEnvironment: apnsEnvironment)
        
        XCTAssertEqual(containerConfig.containerIdentifier, containerID)
        XCTAssertEqual(containerConfig.environment, environment)
        XCTAssertEqual(containerConfig.apnsEnvironment, apnsEnvironment)
        XCTAssertEqual(containerConfig.serverToServerKeyAuth!, serverToServerKeyAuth)
        XCTAssertNil(containerConfig.apiTokenAuth)
        
    }
    
    func testInitializingContainerConfigWithDictionary() {
        let containerID = "CONTAINER_ID"
        let environment = "development"
        
        let keyID = "KEY_ID"
        let privateKeyFile = "eckey.pem"
        let privateKeyPassPhrase = "PASSWORD"
        let serverToServerAuthKeyDict: [String: AnyObject] = ["keyID": keyID as NSString, "privateKeyFile": privateKeyFile as NSString, "privateKeyPassPhrase": privateKeyPassPhrase as NSString]
        let serverToServerAuthKey = CKServerToServerKeyAuth(keyID: keyID, privateKeyFile: privateKeyFile, privateKeyPassPhrase: privateKeyPassPhrase)
        
        let dictionary: [String: AnyObject] = [
            "containerIdentifier": containerID as NSString,
            "environment": environment as NSString,
            "serverToServerKeyAuth": serverToServerAuthKeyDict.bridge()
        ]
        
        let containerConfig = CKContainerConfig(dictionary: dictionary)
        if let containerConfig = containerConfig  {
            XCTAssertEqual(containerConfig.containerIdentifier, containerID)
            XCTAssertEqual(containerConfig.environment, .development)
            XCTAssertEqual(containerConfig.apnsEnvironment, .development)
            XCTAssertEqual(containerConfig.serverToServerKeyAuth!, serverToServerAuthKey)
            XCTAssertNil(containerConfig.apiTokenAuth)
        } else {
            XCTAssertNil(containerConfig)
        }
    }
    
    func testInitializingConfigWithFile() {
        
        let filePath = "\(pathForTests())/Supporting/config.json"
        let config = try? CKConfig(contentsOfFile: filePath)
        if let config = config {
            
            XCTAssertNotNil(config.containers.first)
            let container = config.containers.first!
            XCTAssertEqual(container.containerIdentifier, "com.example.apple-samplecode.cloudkit-catalog")
            XCTAssertEqual(container.environment, .development)
            XCTAssertNotNil(container.serverToServerKeyAuth)
            
        } else {
            XCTAssertNotNil(config)
        }
    }
}
