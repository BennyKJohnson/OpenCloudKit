//
//  CKQuery.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation

struct CKQueryDictionary {
    static let recordType = "recordType"
    static let filterBy = "filterBy"
    static let sortBy = "sortBy"
}

struct CKSortDescriptorDictionary {
    static let fieldName = "fieldName"
    static let ascending = "ascending"
    static let relativeLocation = "relativeLocation"
}

public class CKQuery {
    
    public var recordType: String
    
    public var predicate: Predicate
    
    public init(recordType: String, predicate: Predicate) {
        self.recordType = recordType
        self.predicate = predicate
    }
    
    public var sortDescriptors: [SortDescriptor] = []
    
    // Returns a Dictionary Representation of a Query Dictionary
    var dictionary: [String: AnyObject] {
        
        var queryDictionary: [String: AnyObject] = ["recordType": recordType]
        
        queryDictionary["filterBy"] = []
        
        // Create Sort Descriptor Dictionaries
        queryDictionary["sortBy"] = sortDescriptors.flatMap { (sortDescriptor) -> [String: AnyObject]? in
            if let fieldName = sortDescriptor.key {
                return [CKSortDescriptorDictionary.fieldName: fieldName,
                        CKSortDescriptorDictionary.ascending: sortDescriptor.ascending]
            } else {
                return nil
            }
        }
        
        return queryDictionary
    }
}
