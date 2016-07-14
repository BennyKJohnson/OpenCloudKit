import Foundation

public enum CKEnvironment: String {
    case development
    case production
}

enum CKOperationType {
    case create
    case update
    case replace
    case forceReplace
}




class CloudKit {
    
    static let path = "https://api.apple-cloudkit.com"
    
    static let version = "1"
    
    static let defaultZone = "_defaultZone"
    
    static let defaultName = "_defaultName"
    
    var environment: CKEnvironment = .development
    
    var containers: [CKContainerConfig] = []
    
    static let shared = CloudKit()
    
    private init() {}
    
    func configure(with configuration: CKConfig) {
        self.containers = configuration.containers
        
        if let defaultContainer = containers.first {
            CKWebRequest.shared.currentAPIToken = defaultContainer.apiTokenAuth
        }
    }
}

extension CKRecordID {
    var isDefaultName: Bool {
        return recordName == CloudKit.defaultName
    }
}


public class CKRecordZoneID {
    
    public init(zoneName: String, ownerName: String) {
        self.zoneName = zoneName
        self.ownerName = ownerName
    }
    
    public let zoneName: String
    
    public let ownerName: String
    
    var dictionary: [String: AnyObject] {
        return ["zoneName": zoneName]
    }
}


extension CKRecordZoneID {
    var isDefaultZone: Bool {
        return zoneName == CloudKit.defaultZone
    }
    
    convenience init?(dictionary: [String: AnyObject]) {
        guard let zoneName = dictionary["zoneName"] as? String, ownerName = dictionary["ownerRecordName"] as? String else {
            return nil
        }
        
        self.init(zoneName: zoneName, ownerName: ownerName)
    }
}



public class Location: NSObject {
    
    public let coordinate: LocationCoordinate2D
    
    public init(latitude: Double, longitude: Double) {
        self.coordinate = LocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}

public struct LocationCoordinate2D {
    
    public var latitude: Double
    
    public var longitude: Double
    
    public init() {
        latitude = 0
        longitude = 0
    }
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}




extension NSString : CKRecordValue {
}

extension NSNumber : CKRecordValue {
}

extension NSArray : CKRecordValue {
}

extension NSDate : CKRecordValue {
}

extension NSData : CKRecordValue {
}

extension Location: CKRecordValue {
}



