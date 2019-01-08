

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
    
    // Temporary property to allow for debugging via console
    public var verbose: Bool = false
    
    public weak var delegate: OpenCloudKitDelegate?
    
    var pushConnections: [CKPushConnection] = []
    
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
    
    static func debugPrint(_ items: Any...) {
        if shared.verbose {
            print(items)
        }
    }
    
    func createPushConnection(for url: URL) {
        let connection = CKPushConnection(url: url)
        connection.callBack = {
            (notification) in
            
            self.delegate?.didRecieveRemoteNotification(notification)
        }
        
        pushConnections.append(connection)
    }
    
    public func registerForRemoteNotifications() {
        
        // Setup Create Token Operation
        let createTokenOperation = CKTokenCreateOperation(apnsEnvironment: environment)
        createTokenOperation.createTokenCompletionBlock = {
            (info, error) in
            
            if let info = info {
                // Register Token
                let registerOperation = CKRegisterTokenOperation(apnsEnvironment: info.apnsEnvironment, apnsToken: info.apnsToken)
                registerOperation.registerTokenCompletionBlock = {
                    (tokenInfo, error) in
                    
                    if let error = error {
                        // Notify delegate of error when registering for notifications
                        self.delegate?.didFailToRegisterForRemoteNotifications(withError: error)
                    } else if let info = tokenInfo {
                        // Notify Delegate
                        self.delegate?.didRegisterForRemoteNotifications(withToken: info.apnsToken)
                        
                        // Start connection with token 
                        self.createPushConnection(for: info.webcourierURL)
                        
                        
                    }
                }
                registerOperation.start()
                
            } else if let error = error {
                // Notify delegate of error when registering for notifications
                self.delegate?.didFailToRegisterForRemoteNotifications(withError: error)
                
            }
        }
        
        createTokenOperation.start()
    }
    
    
}

public protocol OpenCloudKitDelegate: class {
    
    func didRecieveRemoteNotification(_ notification:CKNotification)
    
    func didFailToRegisterForRemoteNotifications(withError error: Error)
    
    func didRegisterForRemoteNotifications(withToken token: Data)
    
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

    convenience public required init?(dictionary: [String: Any]) {
        guard let zoneName = dictionary["zoneName"] as? String, let ownerName = dictionary["ownerRecordName"] as? String else {
            return nil
        }
        
        self.init(zoneName: zoneName, ownerName: ownerName)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CKRecordZoneID else { return false }
        return self.zoneName == other.zoneName && self.ownerName == other.ownerName
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












