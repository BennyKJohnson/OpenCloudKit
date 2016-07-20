//
//  Compatibility.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/07/2016.
//
//

import Foundation

#if os(Linux)
    typealias Operation = NSOperation
    typealias PersonNameComponents = NSPersonNameComponents
    typealias FileManager = NSFileManager
    typealias URL = NSURL
    typealias URLSession = NSURLSession
#endif