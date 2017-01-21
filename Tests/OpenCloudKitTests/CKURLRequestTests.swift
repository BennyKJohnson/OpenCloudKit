//
//  CKURLRequestTests.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 28/07/2016.
//
//

import XCTest
@testable import OpenCloudKit
import Foundation

class CKURLRequestTests: XCTestCase {
    

    let containerID = "iCloud.benjamin.CloudTest"
    let environment: CKEnvironment = .development
    let apiToken = "AUTH_KEY"
    let databaseScope = CKDatabaseScope.public
    
    override func setUp() {
        super.setUp()
        
        let containerConfig = CKContainerConfig(containerIdentifier: containerID, environment: environment, apiTokenAuth: apiToken)
        CloudKit.shared.configure(with: CKConfig(container: containerConfig))
    }
    
    func testCKQueryURLRequestURL() {
        
        let queryURLRequest = CKQueryURLRequest(query: CKQuery(recordType: "Items", predicate: NSPredicate(value: true)), cursor: nil, limit: 0, requestedFields: nil, zoneID: nil)
        
        
        let queryURLComponents = URLComponents(url: queryURLRequest.url, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(queryURLComponents.host!, "api.apple-cloudkit.com")
        XCTAssertEqual(queryURLComponents.path, "/database/1/\(containerID)/\(environment)/\(databaseScope)/records/query")
    }
    
    func testCKModifySubscriptionsURLRequestURL() {
        
        let subscriptionURLRequest = CKModifySubscriptionsURLRequest(subscriptionsToSave: nil, subscriptionIDsToDelete: nil)
        
        let urlComponents = URLComponents(url: subscriptionURLRequest.url, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(urlComponents.path, "/database/1/\(containerID)/\(environment)/\(databaseScope)/subscriptions/modify")
    }
    
    func testCKModifyRecordsURL() {
        let modifySubscriptionsURLRequest = CKModifyRecordsURLRequest(recordsToSave: nil, recordIDsToDelete: nil, isAtomic: true, database: CKContainer.default().publicCloudDatabase, savePolicy: .ChangedKeys, zoneID: nil)
        
        let urlComponents = URLComponents(url: modifySubscriptionsURLRequest.url, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(urlComponents.path, "/database/1/\(containerID)/\(environment)/\(databaseScope)/records/modify")
    }
    
    func assertDatabasePath(components: URLComponents, query: String) {
        XCTAssertEqual(components.host, "api.apple-cloudkit.com")
        XCTAssertEqual(components.path, "/database/1/\(containerID)/\(environment)/\(databaseScope)/\(query)")
        
    }
    
}
