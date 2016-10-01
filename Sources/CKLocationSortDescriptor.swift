//
//  CKLocationSortDescriptor.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/07/2016.
//
//

import Foundation

public class CKLocationSortDescriptor: NSSortDescriptor {
    
    public init(key: String, relativeLocation: CKLocationType) {
        self.relativeLocation = relativeLocation
        super.init(key: key, ascending: true)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var relativeLocation: CKLocationType
    
}
