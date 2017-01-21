import XCTest
@testable import OpenCloudKitTests

XCTMain([
     testCase(OpenCloudKitTests.allTests),
     testCase(CKPredicateTests.allTests),
     testCase(CKConfigTests.allTests),
     testCase(CKRecordTests.allTests),
     testCase(CKShareMetadataTests.allTests),
     testCase(CKURLRequestTests.allTests),
     
])
