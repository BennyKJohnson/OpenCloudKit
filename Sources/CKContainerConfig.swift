//
//  CKContainerConfig.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 14/07/2016.
//
//

import Foundation

public struct CKConfig {
    
    let containers: [CKContainerConfig]
    
    public init(containers: [CKContainerConfig]) {
        self.containers = containers
    }
    
    public init(container: CKContainerConfig) {
        self.containers = [container]
    }
    
    init?(dictionary: [String: AnyObject]) {
        guard let containerDictionaries = dictionary["containers"] as? [[String: AnyObject]] else {
            return nil
        }
        
        let containers = containerDictionaries.flatMap { (containerDictionary) -> CKContainerConfig? in
            return CKContainerConfig(dictionary: containerDictionary)
        }
        
        if containers.count > 0 {
            self.containers = containers
        } else {
            return nil
        }
    }
    
    public init?(contentsOfFile path: String) {
        do {
            let jsonData = try NSData(contentsOfFile: path, options: [])
            if let dictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: []) as? [String: AnyObject] {
                self.init(dictionary: dictionary)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

public struct CKContainerConfig {
    public let containerIdentifier: String
    public let environment: CKEnvironment
    public let apnsEnvironment: CKEnvironment
    public let apiTokenAuth: String?
    public let serverToServerKeyAuth: CKServerToServerKeyAuth?
    
    public init(containerIdentifier: String, environment: CKEnvironment,apiTokenAuth: String, apnsEnvironment: CKEnvironment? = nil) {
        self.containerIdentifier = containerIdentifier
        self.environment = environment
        if let apnsEnvironment = apnsEnvironment {
            self.apnsEnvironment = apnsEnvironment
        } else {
            self.apnsEnvironment = environment
        }
        
        self.apiTokenAuth = apiTokenAuth
        self.serverToServerKeyAuth = nil
    }
    
    public init(containerIdentifier: String, environment: CKEnvironment, serverToServerKeyAuth: CKServerToServerKeyAuth, apnsEnvironment: CKEnvironment? = nil) {
        self.containerIdentifier = containerIdentifier
        self.environment = environment
        if let apnsEnvironment = apnsEnvironment {
            self.apnsEnvironment = apnsEnvironment
        } else {
            self.apnsEnvironment = environment
        }
        self.apiTokenAuth = nil
        self.serverToServerKeyAuth = serverToServerKeyAuth
    }
    
    init?(dictionary: [String: AnyObject]) {
        guard let containerIdentifier = dictionary["containerIdentifier"] as? String, environmentValue = dictionary["environment"] as? String,
            environment = CKEnvironment(rawValue: environmentValue)  else {
            return nil
        }
        
        let apnsEnvironment = CKEnvironment(rawValue: dictionary["apnsEnvironment"] as? String ?? "")
        
        if let apiTokenAuthDictionary = dictionary["apiTokenAuth"] as? [String: AnyObject] {
            
            if let apiToken = apiTokenAuthDictionary["apiToken"] as? String {
                self.init(containerIdentifier: containerIdentifier, environment: environment, apiTokenAuth: apiToken, apnsEnvironment: apnsEnvironment)
            } else {
                return nil
            }
            
        } else if let serverToServerKeyAuthDictionary = dictionary["serverToServerKeyAuth"] as? [String: AnyObject] {
            guard let keyID = serverToServerKeyAuthDictionary["keyID"] as? String, privateKeyFile = serverToServerKeyAuthDictionary["privateKeyFile"] as? String else {
                return nil
            }
            
            let privateKeyPassPhrase = serverToServerKeyAuthDictionary["privateKeyPassPhrase"] as? String
            let auth = CKServerToServerKeyAuth(keyID: keyID, privateKeyFile: privateKeyFile, privateKeyPassPhrase: privateKeyPassPhrase)
            
            self.init(containerIdentifier: containerIdentifier, environment: environment, serverToServerKeyAuth: auth, apnsEnvironment: apnsEnvironment)

        } else {
            return nil
        }
    }
}

public struct CKServerToServerKeyAuth: Equatable {
    // A unique identifier for the key generated using CloudKit Dashboard. To create this key, read
    let keyID: String
    // The path to the PEM encoded key file.
    let privateKeyFile: String
    
    //The pass phrase for the key.
    let privateKeyPassPhrase: String?
}


public func ==(lhs: CKServerToServerKeyAuth, rhs: CKServerToServerKeyAuth) -> Bool {
    return lhs.keyID == rhs.keyID && lhs.privateKeyFile == rhs.privateKeyFile && lhs.privateKeyPassPhrase == rhs.privateKeyPassPhrase
}
