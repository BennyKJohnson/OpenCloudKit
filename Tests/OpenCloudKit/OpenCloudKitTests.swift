import XCTest
@testable import OpenCloudKit

class OpenCloudKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(OpenCloudKit().text, "Hello, World!")
    }


    static var allTests : [(String, (OpenCloudKitTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
