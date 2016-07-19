//
//  CKPersonNameComponents.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/07/2016.
//
//

import Foundation


public protocol CKPersonNameComponentsType {
    
    var namePrefix: String? { get set }
    
    /* Name bestowed upon an individual by one's parents, e.g. Johnathan */
    var givenName: String? { get set }
    
    /* Secondary given name chosen to differentiate those with the same first name, e.g. Maple  */
    var middleName: String? { get set }
    
    /* Name passed from one generation to another to indicate lineage, e.g. Appleseed  */
    var familyName: String? { get set }
    
    /* Post-nominal letters denoting degree, accreditation, or other honor, e.g. Esq., Jr., Ph.D. */
    var nameSuffix: String? { get set }
    
    /* Name substituted for the purposes of familiarity, e.g. "Johnny"*/
    var nickname: String? { get set }
    
    init?(dictionary: [String: AnyObject])
}

public struct CKPersonNameComponents {
    
    /* Pre-nominal letters denoting title, salutation, or honorific, e.g. Dr., Mr. */
    public var namePrefix: String?
    
    /* Name bestowed upon an individual by one's parents, e.g. Johnathan */
    public var givenName: String?
    
    /* Secondary given name chosen to differentiate those with the same first name, e.g. Maple  */
    public var middleName: String?
    
    /* Name passed from one generation to another to indicate lineage, e.g. Appleseed  */
    public var familyName: String?
    
    /* Post-nominal letters denoting degree, accreditation, or other honor, e.g. Esq., Jr., Ph.D. */
    public var nameSuffix: String?
    
    /* Name substituted for the purposes of familiarity, e.g. "Johnny"*/
    public var nickname: String?
    
    /* Each element of the phoneticRepresentation should correspond to an element of the original PersonNameComponents instance.
     The phoneticRepresentation of the phoneticRepresentation object itself will be ignored. nil by default, must be instantiated.
     */
}

extension CKPersonNameComponents: CKPersonNameComponentsType {
    public init?(dictionary: [String: AnyObject]) {
  
        namePrefix = dictionary["namePrefix"] as? String
        givenName = dictionary["givenName"] as? String
        familyName = dictionary["familyName"] as? String
        nickname = dictionary["nickname"] as? String
        nameSuffix = dictionary["nameSuffix"] as? String
        middleName = dictionary["middleName"] as? String
        // phoneticRepresentation
    }
}


@available(OSX 10.11, *)
extension PersonNameComponents: CKPersonNameComponentsType {
    public init?(dictionary: [String: AnyObject]) {
        self.init()
        
        namePrefix = dictionary["namePrefix"] as? String
        givenName = dictionary["givenName"] as? String
        familyName = dictionary["familyName"] as? String
        nickname = dictionary["nickname"] as? String
        nameSuffix = dictionary["nameSuffix"] as? String
        middleName = dictionary["middleName"] as? String
        // phoneticRepresentation
    }
}
