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

public class CloudKit {
    
    static let path = "https://api.apple-cloudkit.com"
    
    static let version = "1"
    
    public var environment: CKEnvironment = .development
    
    public private(set) var containers: [CKContainerConfig] = []
    
    public static let shared = CloudKit()
    
    private init() {}
    
   public func configure(with configuration: CKConfig) {
        self.containers = configuration.containers
    }
    
    func containerConfig(forContainer container: CKContainer) -> CKContainerConfig? {
        return containers.filter({ (config) -> Bool in
            return config.containerIdentifier == container.containerIdentifier
        }).first
    }
}

extension CKRecordID {
    var isDefaultName: Bool {
        return recordName == CKRecordZoneDefaultName
    }
}


public class CKRecordZoneID: NSObject {
    
    public init(zoneName: String, ownerName: String) {
        self.zoneName = zoneName
        self.ownerName = ownerName
        super.init()
        
    }
    
    public let zoneName: String
    
    public let ownerName: String
    
    
    convenience public required init?(dictionary: [String: AnyObject]) {
        guard let zoneName = dictionary["zoneName"] as? String, ownerName = dictionary["ownerRecordName"] as? String else {
            return nil
        }
        
        self.init(zoneName: zoneName, ownerName: ownerName)
    }
    
}


extension CKRecordZoneID {
    

    var dictionary: [String: AnyObject] {
        
        var zoneIDDictionary: [String: AnyObject] = [
        "zoneName": zoneName
        ]
        
        if ownerName != CKRecordZoneIDDefaultOwnerName {
            zoneIDDictionary["ownerRecordName"] = ownerName
        }
        
        return zoneIDDictionary
    }
}












