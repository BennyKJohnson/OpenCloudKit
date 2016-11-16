//
//  CKRecordTests.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 15/11/16.
//
//

import XCTest
@testable import OpenCloudKit

class CKRecordTests: XCTestCase {
    
    static var allTests : [(String, (CKRecordTests) -> () throws -> Void)] {
        return [
            ("testSetIntValueForKey", testSetIntValueForKey),
            ("testSetDoubleValueForKey", testSetDoubleValueForKey),
            ("testSetFloatValueForKey", testSetFloatValueForKey),
            ("testSetUIntValueForKey", testSetUIntValueForKey),
            ("testSetStringValueForKey", testSetStringValueForKey),
            ("testJSONObjectForIntValue", testJSONObjectForIntValue),
            ("testJSONObjectForFloatValue", testJSONObjectForFloatValue),
            ("testJSONObjectForUIntValue", testJSONObjectForUIntValue),
            ("testJSONObjectForStringValue", testJSONObjectForStringValue),
            ("testJSONSerializationOfRecordValueStringArray", testJSONSerializationOfRecordValueStringArray)
        ]
    }
    
    let record = CKRecord(recordType: "Movie")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetIntValueForKey() {
        record["int"] = 5
        let intValue = record["int"] as? Int
        XCTAssertEqual(intValue, 5)
    }
    
    func testSetDoubleValueForKey() {
        let val: Double = 1.2345
        record["double"] = val
        
        let doubleValue = record["double"] as? Double
        XCTAssertEqual(doubleValue, val)
    }
    
    func testSetFloatValueForKey() {
        let val: Float = 6.57
        record["float"] = val
        
        let floatValue = record["float"] as? Float
        XCTAssertEqual(floatValue, val)
    }
    
    func testSetUIntValueForKey() {
        let val:UInt = 3
        record["uint"] = val
        
        let uintValue = record["uint"] as? UInt
        XCTAssertEqual(uintValue, val)
    }
    
    func testSetStringValueForKey() {
        let string = "MySwiftString"
        record["string"] = string
        
        let stringValue = record["string"] as? String
        XCTAssertEqual(stringValue, string)
    }
    
    func testJSONObjectForIntValue() {
        record["int"] = 5
        let dictionary = record["int"]!.recordFieldDictionary.bridge()
        let expectedResult = ["value": NSNumber(value: 5)].bridge()
        
        XCTAssertEqual(dictionary, expectedResult)
    }
    
    func testJSONObjectForFloatValue() {
        let val: Float = 1.23
        record["float"] = val
        let dictionary = record["float"]!.recordFieldDictionary.bridge()
        let expectedResult = ["value": NSNumber(value: val)].bridge()
        
        XCTAssertEqual(dictionary, expectedResult)
    }
    
    func testJSONObjectForUIntValue() {
        let val: UInt = 4
        record["uint"] = val
        
        let dictionary = record["uint"]!.recordFieldDictionary.bridge()
        let expectedResult = ["value": NSNumber(value: val)].bridge()
        XCTAssertEqual(dictionary, expectedResult)

    }
    
    func testJSONObjectForStringValue() {
        
        let string = "MySwiftString"
        record["string"] = string
        
        let dictionary = record["string"]!.recordFieldDictionary.bridge()
        let expectedResult = ["value": string.bridge(), "type":"STRING".bridge()].bridge()
        XCTAssertEqual(dictionary, expectedResult)
    }
    
    func testJSONSerializationOfRecordValueStringArray() {
        let movieRecord = CKRecord(recordType: "Movie")
        movieRecord["title"] = "Finding Dory"
        movieRecord["directors"] = NSArray(array: ["Andrew Stanton", "Angus MacLane"])
        
        let directorsJSONObject = movieRecord["directors"]!.recordFieldDictionary.bridge()
        let jsonObject = try? JSONSerialization.data(withJSONObject: directorsJSONObject, options: [.prettyPrinted])
        XCTAssertNotNil(jsonObject)
    }
    
    
}
