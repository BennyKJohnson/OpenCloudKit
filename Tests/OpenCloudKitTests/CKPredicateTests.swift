//
//  CKPredicateTests.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/07/2016.
//
//

import XCTest
@testable import OpenCloudKit

class CKPredicateTests: XCTestCase {

    func testParseLocationFunction() {
        let testString = "distanceToLocation:fromLocation:(Location, <-33.00000000,+150.00000000> +/- 0.00m (speed -1.00 mps / course -1.0))"
        let reader = CKPredicateReader(string: testString)
        let function = try! reader.parseFunction(0)
        
        XCTAssertEqual("distanceToLocation:fromLocation:", function.0)
        XCTAssertEqual("Location", function.parameters[0] as! String)
        XCTAssertEqual("<-33.00000000,+150.00000000> +/- 0.00m (speed -1.00 mps / course -1.0)", function.parameters[1] as! String)
    }
    
    func testParseLocation() {
       let testString = "<-33.00000000,+150.00000000> +/- 0.00m (speed -1.00 mps / course -1.0)"
        let reader = CKPredicateReader(string: testString)
        let coordinate = try! reader.parseLocation(index: 0)
        XCTAssertNotNil(coordinate)
       // XCTAssertEqualWithAccuracy(coordinate?.0!, , accuracy: <#T##T#>)
        
    }
    
    func testParseLocationExpression() {
        let testString = "distanceToLocation:fromLocation:(address, <-33.00000000,+150.00000000> +/- 0.00m (speed -1.00 mps / course -1.0))"
        let reader = CKPredicateReader(string: testString)
        let result = try! reader.parseLocationExpression(0)
        XCTAssertNotNil(result)
        XCTAssertEqual("address", result!.fieldName)
        let coordinate = result!.coordinate
        XCTAssertEqualWithAccuracy(coordinate.latitude, -33.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(coordinate.longitude, 150.0, accuracy: 0.001)
    }
    
    func testFunctionParse() {
        
        let functionString = "CAST(490594046.671135, \"NSDate\")"
        let reader = CKPredicateReader(string: functionString)
        let function = try! reader.parseFunction(0)
        XCTAssertEqual(function.0, "CAST")
        XCTAssertEqual(function.parameters.count, 2)
        XCTAssertTrue(function.parameters[0] is NSNumber)
        XCTAssertEqual(function.parameters[1] as! String, "NSDate")
    }
    
    func testParsingCompoundPredicate() {
        
        let predicate = NSPredicate(format: "age == 40 && price > 67")
        let parsedPredicate = CKPredicate(predicate: predicate)
        
        XCTAssertEqual(parsedPredicate.compoundPredicates(with: parsedPredicate.predicate.predicateFormat), ["age == 40", "price > 67"])
        
    }
    
    func testParsingComponents() {
        let predicate = NSPredicate(format: "age == 40")
        let parsedPredicate = CKPredicate(predicate: predicate)
        XCTAssertEqual(parsedPredicate.components(for: parsedPredicate.predicate.predicateFormat), ["age", "==", "40"])
    }
    
    func testParsingComponents2() {
        let predicate = NSPredicate(format: "name = Benjamin")
        let parsedPredicate = CKPredicate(predicate: predicate)
        XCTAssertEqual(parsedPredicate.components(for: parsedPredicate.predicate.predicateFormat), ["name", "==", "Benjamin"])
    }
    
    func testParsingEqualsPredicate() {
        let predicate = NSPredicate(format: "name = %@", "Benjamin")
        let ckPredicate = CKPredicate(predicate: predicate)
        
        let expectedResult = CKQueryFilter(fieldName: "name", comparator: .equals, fieldValue: "Benjamin")
        XCTAssertEqual(ckPredicate.filters().first!, expectedResult)
    }
    
    func testParsingLessThanPredicate() {
        let predicate = NSPredicate(format: "year < 2005")
        let ckPredicate = CKPredicate(predicate: predicate)
        
        let expectedResult = CKQueryFilter(fieldName: "year", comparator: .lessThan, fieldValue: 2005)
        XCTAssertEqual(ckPredicate.filters().first!, expectedResult)
    }
    
    func testParsingGreaterThanPredicate() {
        let predicate = NSPredicate(format: "year > 2005")
        let ckPredicate = CKPredicate(predicate: predicate)
        
        let expectedResult = CKQueryFilter(fieldName: "year", comparator: .greaterThan, fieldValue: 2005)
        XCTAssertEqual(ckPredicate.filters().first!, expectedResult)

    }
    
    func testParsingDatePredicate() {
        let date = NSDate()
        let predicate = NSPredicate(format: "lastUpdated > %@", date)
        print(predicate.predicateFormat)
        let ckPredicate = CKPredicate(predicate: predicate)
        
        let expectedResult = CKQueryFilter(fieldName: "lastUpdated", comparator: .greaterThan, fieldValue: date)
        
        XCTAssertEqual(ckPredicate.filters().first!, expectedResult)
    }
    
    func testParsingLocationPredicate() {
        
        let radiusInKilometers = 5000.0 / 1000.0
        
        let location = CKLocation(latitude: -33.8688, longitude: 151.2093)

        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f",
                                            "Location",
                                            location,
                                            radiusInKilometers)
       
        let expectedResult = CKQueryFilter(fieldName: "Location", comparator: .lessThan, fieldValue: location)
        let predicate = CKPredicate(predicate: locationPredicate)
        XCTAssertEqual(predicate.filters().first!, expectedResult)
    }
    
    func testFilterDictionary() {
        let filter = CKQueryFilter(fieldName: "name", comparator: .equals, fieldValue: "jack")
        let filterDictionary = filter.dictionary
        let expectedDictionary: [String: Any] = ["comparator": "EQUALS".bridge(), "fieldName": "name".bridge(), "fieldValue": "jack".bridge()]
        
        XCTAssertEqual(filterDictionary["comparator"] as! String, expectedDictionary["comparator"] as! String)
        XCTAssertEqual(filterDictionary["fieldName"] as! String, expectedDictionary["fieldName"] as! String)
        let recordValueDictionary = filterDictionary["fieldValue"] as! [String: Any]
        
        XCTAssertEqual(recordValueDictionary["value"] as! String, "jack")
        XCTAssertEqual(recordValueDictionary["type"] as! String, "STRING")
    }
    
    func testFilterDictionaryWithNumber() {
        let filter = CKQueryFilter(fieldName: "year", comparator: .lessThan, fieldValue: 2010)
        let filterDictionary = filter.dictionary

        let recordValueDictionary = filterDictionary["fieldValue"] as! [String: Any]
        
        XCTAssertEqual(recordValueDictionary["value"] as! NSNumber, NSNumber(value: 2010))
    }
    
    func testFilterDictionaryWithLocation() {
        let location = CKLocation(latitude: -33.8688, longitude: 151.2093)
        let filter = CKQueryFilter(fieldName: "location", comparator: .lessThan, fieldValue: location, distance: 1000)
        let filterDictionary = filter.dictionary
        XCTAssertEqual(filterDictionary["comparator"] as! String, "LESS_THAN")
        XCTAssertEqual(filterDictionary["distance"] as! NSNumber, 1000)

        let recordValueDictionary = filterDictionary["fieldValue"] as! [String: Any]
        
        XCTAssertNotNil(recordValueDictionary["value"] as? [String: Any])
        XCTAssertEqual(recordValueDictionary["type"] as! String, "LOCATION")
    }

}
