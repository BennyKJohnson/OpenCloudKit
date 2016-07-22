//
//  CKPredicate.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/07/2016.
//
//

import Foundation

enum CompatorValue: String {
    case equals = "EQUALS"
    case notEquals = "NOT_EQUALS"
    case lessThan = "LESS_THAN"
    case lessThanOrEquals = "LESS_THAN_OR_EQUALS"
    case greaterThan = "GREATER_THAN"
    case greaterThanOrEquals = "GREATER_THAN_OR_EQUALS"
    case near = "NEAR"
    case containsAllTokens = "CONTAINS_ALL_TOKENS"
    case `in` = "IN"
    case notIn = "NOT_IN"
    case containsAnyTokens = "CONTAINS_ANY_TOKENS"
    case listContains = "LIST_CONTAINS"
    case notListContains = "NOT_LIST_CONTAINS"
    case notListContainsAny = "NOT_LIST_CONTAINS_ANY"
    case beginsWith = "BEGINS_WITH"
    case notBeginsWith = "NOT_BEGINS_WITH"
    case listMemberBeginsWith = "LIST_MEMBER_BEGINS_WITH"
    case notListMemberBeginsWith = "NOT_LIST_MEMBER_BEGINS_WITH"
    case listContainsAll = "LIST_CONTAINS_ALL"
    case notListContainsAll = "NOT_LIST_CONTAINS_ALL"
    
    init?(expression: String) {
        switch expression {
        case "==":
            self = .equals
        case "!=":
            self = .notEquals
        case "<":
            self = .lessThan
        case "<=":
            self = .lessThanOrEquals
        case ">":
            self = .greaterThan
        case ">=":
            self  = .greaterThanOrEquals
        default:
            return nil
        }
    }
}


struct CKPredicate {
    
    struct TokenPosition {
        var index: Int
        var length: Int
        
        init(index: Int) {
            self.index = index
            self.length = 0
        }
        mutating func advance() {
            length += 1
        }
    }
    
    let predicate: Predicate
    
    let numberFormatter = NumberFormatter()
    
    init(predicate: Predicate) {
        self.predicate = predicate
    }
    
    func compoundPredicates(with format: String) -> [String] {
        let compoundPredicateComponents = format.components(separatedBy: " AND ")
        return compoundPredicateComponents
    }
    
    func filters() -> [CKFilter] {
        var filterDictionaries: [CKFilter] = []
        let compoundPredicates = self.compoundPredicates(with: predicate.predicateFormat)
        for predicate in compoundPredicates {
            let components = self.components(for: predicate)
            if let filterDictionary = try! filterPredicate(components: components) {
                filterDictionaries.append(filterDictionary)
            }
        }
        
        if filterDictionaries.count == compoundPredicates.count {
            return filterDictionaries
        } else {
            return []
        }
    }
    
    func components(for string: String) -> [String] {
        
        let reader = CKPredicateReader(string: string)
        return try! reader.parse(0)
    }
    
    func filterPredicate(components: [String]) throws -> CKFilter? {
        if components.count == 3 {
            let lhs = components[0]
            var fieldName = lhs
            let comparatorValue = components[1]
            let rhs = value(forString: components[2])
            var fieldValue = rhs
                        
            guard  let comparator = CompatorValue(expression: comparatorValue) else {
                return nil
            }
            
            if lhs.hasPrefix("distanceToLocation:fromLocation:") {
                // Parse Location Function
                let locationReader = CKPredicateReader(string: fieldName)
                if let locationExpression = try! locationReader.parseLocationExpression(0) {
                    fieldName = locationExpression.fieldName
                    let coordinate = locationExpression.coordinate
                    fieldValue = CKLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    if let distance = (rhs as? NSNumber)?.doubleValue {
                        return CKFilter(fieldName: fieldName, comparator: comparator, fieldValue: fieldValue, distance: distance)
                    }
                }
            }
            
            return CKFilter(fieldName: fieldName, comparator: comparator, fieldValue: fieldValue)
        } else if components.count == 1 {
            if components[0] == "TRUEPREDICATE" {
                return nil
            }
        }
        
        return nil
    }
    
    func parseFunction(string: String) -> CKPredicateFunction? {
        let functionReader = CKPredicateReader(string: string)
        do {
            let parsedFunction = try functionReader.parseFunction(0)
            return CKPredicateFunction(name: parsedFunction.0, parameters: parsedFunction.parameters)
        } catch {
            return nil
        }
    }
    
    func value(forCastParameters parameters: [AnyObject]) -> CKRecordValue? {
        let type = parameters.last as! String
        switch type {
        case "NSDate":
            let interval = parameters.first as! NSNumber
            return NSDate(timeIntervalSinceReferenceDate: interval.doubleValue)
            
        default:
            return nil
        }
    }
    
    func value(forString string: String) -> CKRecordValue {
        
        #if os(Linux)
        let numberFromString = numberFormatter.numberFromString(string)
        #else
        let numberFromString = numberFormatter.number(from: string)
        #endif
        
        if let number = numberFromString {
            return number
        } else {
            if string.hasPrefix("CAST") {
                // Parse Function
                let parseFunction = self.parseFunction(string: string)
                return value(forCastParameters: parseFunction!.parameters)!
                
            } else {
                return string.bridge()
            }
        }
    }
}

public struct CKPredicateFunction {
    let name: String
    let parameters: [AnyObject]
}

public struct CKFilter: Equatable {
    let fieldName: String
    let comparator: CompatorValue
    let fieldValue: CKRecordValue
    let distance: CKLocationDistance?
    
    init(fieldName: String, comparator: CompatorValue, fieldValue: CKRecordValue, distance: CKLocationDistance? = nil) {
        self.fieldName = fieldName
        self.comparator = comparator
        self.fieldValue = fieldValue
        self.distance = distance
    }
}

extension CKFilter: CustomDictionaryConvertible {
    
    public var dictionary: [String: AnyObject] {
        var filterDictionary: [String: AnyObject] = [
        "comparator": comparator.rawValue.bridge(),
        "fieldName": fieldName.bridge(),
        "fieldValue": fieldValue.recordFieldDictionary.bridge()
        ]
        
        if let distance = distance {
            filterDictionary["distance"] = NSNumber(value: distance)
        }
        
        return filterDictionary
    }
}

public func ==(lhs: CKFilter, rhs: CKFilter) -> Bool {
    return lhs.fieldName == rhs.fieldName && lhs.comparator == rhs.comparator && lhs.fieldValue.isEqual(rhs.fieldValue as! AnyObject)
}
