//
//  CKLocation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/07/2016.
//
//

import Foundation

public protocol CKLocationType: CustomDictionaryConvertible {
    
    var coordinateType: CKLocationCoordinate2DType { get }
    
    var altitude: CKLocationDistance { get }
    
    var horizontalAccuracy: CKLocationAccuracy { get }
    
    var verticalAccuracy: CKLocationAccuracy { get }
    
    var course: CKLocationDirection { get }
    
    var speed: CKLocationSpeed { get }
    
    var timestamp: Date { get }
}

public protocol CKLocationCoordinate2DType {
    
    var latitude: CKLocationDegrees { get }
    
    var longitude: CKLocationDegrees { get }
    
}

public typealias CKLocationDegrees = Double

public typealias CKLocationDistance = Double

public typealias CKLocationAccuracy = Double

public typealias CKLocationSpeed = Double

public typealias CKLocationDirection = Double

public struct CKLocationCoordinate2D: Equatable, CKLocationCoordinate2DType {
    
    public var latitude: CKLocationDegrees
    
    public var longitude: CKLocationDegrees
    
    public init() {
        latitude = 0
        longitude = 0
    }
    
    public init(latitude: CKLocationDegrees, longitude: CKLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public func ==(lhs: CKLocationCoordinate2D, rhs: CKLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}


public class CKLocation: NSObject {
    
    public init(latitude: CKLocationDegrees, longitude: CKLocationDegrees) {
        
        self.coordinate = CKLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.altitude = 0
        self.horizontalAccuracy = 0
        self.verticalAccuracy = 0
        self.timestamp = Date()
        self.speed = -1
        self.course = -1
        
    }
    
    public init(coordinate: CKLocationCoordinate2D, altitude: CKLocationDistance, horizontalAccuracy hAccuracy: CKLocationAccuracy, verticalAccuracy vAccuracy: CKLocationAccuracy, timestamp: Date) {
        
        self.coordinate = coordinate
        self.altitude = altitude
        self.horizontalAccuracy = hAccuracy
        self.verticalAccuracy = vAccuracy
        self.timestamp = timestamp
        
        self.speed = -1
        self.course = -1
    }
    
    public init(coordinate: CKLocationCoordinate2D, altitude: CKLocationDistance, horizontalAccuracy hAccuracy: CKLocationAccuracy, verticalAccuracy vAccuracy: CKLocationAccuracy, course: CKLocationDirection, speed: CKLocationSpeed, timestamp: Date) {
        
        self.coordinate = coordinate
        self.altitude = altitude
        self.horizontalAccuracy = hAccuracy
        self.verticalAccuracy = vAccuracy
        self.course = course
        self.speed = speed
        self.timestamp = timestamp
    }
    

    public let coordinate: CKLocationCoordinate2D
    
    public let altitude: CKLocationDistance
    
    public let horizontalAccuracy: CKLocationAccuracy
    
    public let verticalAccuracy: CKLocationAccuracy
    
    public let course: CKLocationDirection
    
    public let speed: CKLocationSpeed
    
    public let timestamp: Date
    
    public override var description: String {
        return "<\(coordinate.latitude),\(coordinate.longitude)> +/- \(horizontalAccuracy)m (speed \(speed) mps / course \(course))"
    }
    
    override public func isEqual(_ object: AnyObject?) -> Bool {
        if let location = object as? CKLocation {
            
            
            return location.coordinate == self.coordinate
        }
        return false
        
    }
}

extension CKLocation: CKLocationType {
    public var coordinateType: CKLocationCoordinate2DType {
        return coordinate
    }
}

extension CKLocationType {
    
    public var dictionary: [String: AnyObject] {
        return [
        "latitude": coordinateType.latitude,
        "longitude": coordinateType.longitude,
        "horizontalAccuracy": horizontalAccuracy,
        "verticalAccuracy": verticalAccuracy,
        "altitude": altitude,
        "speed": speed,
        "course": course,
        "timestamp": timestamp.timeIntervalSince1970
        ]
    }
}

extension CKLocation {
   
}

