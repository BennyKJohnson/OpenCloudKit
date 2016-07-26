//
//  CLLocation+OpenCloudKit.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/07/2016.
//
//

import CoreLocation

extension CLLocationCoordinate2D: CKLocationCoordinate2DType {}

extension CLLocation: CKLocationType {
    public var coordinateType: CKLocationCoordinate2DType {
        return coordinate
    }
}
    


