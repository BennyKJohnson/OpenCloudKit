//
//  CKShareMetadataTests.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 17/10/16.
//
//

import XCTest
@testable import OpenCloudKit

class CKShareMetadataTests: XCTestCase {
    
    let containerID = "iCloud.au.com.benjaminjohnson.Playroom"
    let environment: CKEnvironment = .development
    let apiToken = "69d9716386808b294a5378c1eca316a84c440f3d9f0a684738a0c353a510c14a"
    let databaseScope = CKDatabaseScope.public
    
    func pathForTests() -> String {
        let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
        return parent
    }
    
    func jsonURL() -> URL {
        return URL(fileURLWithPath: "\(pathForTests())/Supporting/sharemetadata.json")
    }
    
    func jsonData() -> Data {
        return try! Data(contentsOf: jsonURL())
    }
    
    func json() -> [String: AnyObject] {
        return try! JSONSerialization.jsonObject(with: jsonData(), options: []) as! [String: AnyObject]
    }
    
    override func setUp() {
        super.setUp()
        
        let containerConfig = CKContainerConfig(containerIdentifier: containerID, environment: environment, apiTokenAuth: apiToken)
        CloudKit.shared.configure(with: CKConfig(container: containerConfig))
        CloudKit.shared.defaultAccount.iCloudAuthToken = "55__39__AT2sc5/W9j51Y5fjoDNpREublhsscmckmN9unZCseJrltfiJ1Ey8Hjg/oTj+O7e5YFfRm2TL5GdxbSyefdqtXSrDq0krIvjsIRFFXatFlT/t+crygvpSHCC7RpPQEAfziO/NknwkbWaEhv2N/8n7KMZXnibqEtzLk501QgRodxm8sR2pQrfQxiQtfoFwF2E/hyvQVhiBd0w=__eyJYLUFQUExFLVdFQkFVVEgtUENTLUNsb3Vka2l0IjoiUVhCd2JEb3hPZ0V6L0ZRNWUyeitvZnNXaUVWdk05OGZwNmFQTUlCbWRremVwTFR2WWkvWGNycjFNbFhGZUg5UXBOUU52MWJqVFRmVFJKN240eHY4cGdCbE16eGtGUENZIiwiWC1BUFBMRS1XRUJBVVRILVBDUy1TaGFyaW5nIjoiUVhCd2JEb3hPZ0ZGdmU1TlBlamp4aU13VFYxTGZnbjRtNE1ZZEVNbUxTUlg0YjE4UXEvRGxGanJxVkRNOWVZSjhUK1pNaWkreXh2RHBZT0lsREJnWDRmSDRTSDFmWUxZIn0="
        
    }
    
    
    func testShareMetadataFromJSON() {
        let shareMetaData = CKShareMetadata(dictionary: json())
        guard let metadata = shareMetaData else {
            XCTAssertNotNil(shareMetaData)
            return
        }
        
        XCTAssertEqual(metadata.containerIdentifier, "iCloud.au.com.benjaminjohnson.test")
        XCTAssert(true)
        
    }
    
    func testAcceptShareOperation() {
        
        let exp = self.expectation(description: "Something")
        let shortGUID = CKShortGUID(value: "0NEa3AEPXwK71VM4gHFnvh2kw", shouldFetchRootRecord: true, rootRecordDesiredKeys: nil)
        let acceptShareOperation = CKAcceptSharesOperation(shortGUIDs: [shortGUID])
        
        acceptShareOperation.acceptSharesCompletionBlock = {
            (error) in
            print(error as Any)
            exp.fulfill()
        }
        
        acceptShareOperation.perShareCompletionBlock = {
            (metaData, share, error) in
            print(metaData)
            
        }
        
        acceptShareOperation.start()
        self.waitForExpectations(timeout: 5.0) { (error) in
            print("Timeout \(error)")
        }
    }
    
}


    
