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
    
    public var environment: CKEnvironment = .development
    
    public var defaultAccount: CKAccount!
    
    public private(set) var containers: [CKContainerConfig] = []
    
    public static let shared = CloudKit()
    
    private init() {}
    
    public func configure(with configuration: CKConfig) {
        self.containers = configuration.containers
        
        // Setup DefaultAccount
        let container = self.containers.first!
        if let serverAuth = container.serverToServerKeyAuth {
            
            // Setup Server Account
            defaultAccount = CKServerAccount(containerInfo: container.containerInfo, keyID: serverAuth.keyID, privateKeyFile: serverAuth.privateKeyFile)
            
        } else if let apiTokenAuth = container.apiTokenAuth {
            // Setup Anoymous Account
            defaultAccount = CKAccount(type: .anoymous, containerInfo: container.containerInfo, cloudKitAuthToken: apiTokenAuth)
        }
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
        guard let zoneName = dictionary["zoneName"] as? String, let ownerName = dictionary["ownerRecordName"] as? String else {
            return nil
        }
        
        self.init(zoneName: zoneName, ownerName: ownerName)
    }
    
}


extension CKRecordZoneID: CKCodable {
    

    var dictionary: [String: Any] {
        
        var zoneIDDictionary: [String: Any] = [
        "zoneName": zoneName.bridge()
        ]
        
        if ownerName != CKRecordZoneIDDefaultOwnerName {
            zoneIDDictionary["ownerRecordName"] = ownerName.bridge()
        }
        
        return zoneIDDictionary
    }
}












