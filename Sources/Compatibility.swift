//
//  Compatibility.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 20/07/2016.
//
//

import Foundation

#if os(OSX) || os(iOS)

let CKUTF8StringEncoding = String.Encoding.utf8.rawValue
    
extension FileManager {
    static var defaultFileManager: FileManager {
        return FileManager.default
    }
}
 
 extension URLSessionConfiguration {
 static func defaultConfiguration() -> URLSessionConfiguration {
 #if os(Linux)
 return URLSessionConfiguration.default()
 #else
 return URLSessionConfiguration.default
 #endif
 }
 }
 


#elseif os(Linux)
//#if os(OSX) || os(iOS)

let CKUTF8StringEncoding = NSUTF8StringEncoding

public typealias Operation = NSOperation
public typealias FileManager = NSFileManager
public typealias URL = NSURL
public typealias URLSession = NSURLSession
public typealias URLSessionDelegate = NSURLSessionDelegate
public typealias URLRequest = NSMutableURLRequest
public typealias DateFormatter = NSDateFormatter
public typealias Date = NSDate
public typealias SortDescriptor = NSSortDescriptor
public typealias URLSessionTask = NSURLSessionTask
public typealias URLSessionDataDelegate = NSURLSessionDataDelegate
public typealias URLSessionDownloadDelegate = NSURLSessionDownloadDelegate
public typealias URLSessionDownloadTask = NSURLSessionDownloadTask
public typealias URLSessionDataTask = NSURLSessionDataTask
public typealias URLSessionConfiguration = NSURLSessionConfiguration
public typealias OperationQueue = NSOperationQueue
public typealias Predicate = NSPredicate
public typealias TimeZone  = NSTimeZone
public typealias Locale =  NSLocale
public typealias JSONSerialization = NSJSONSerialization
public typealias Data = NSData
public typealias URLQueryItem = NSURLQueryItem
public typealias NumberFormatter = NSNumberFormatter
public typealias URLComponents = NSURLComponents
public typealias TimeInterval = NSTimeInterval
public typealias HTTPURLResponse = NSHTTPURLResponse
public typealias CharacterSet = NSCharacterSet
@available(OSX 10.11, *)
public typealias PersonNameComponents = NSPersonNameComponents
    
extension FileManager {
   static var defaultFileManager: NSFileManager {
        return NSFileManager.default()
    }
}

extension CharacterSet {
    static var urlQueryAllowed: CharacterSet {
        return CharacterSet.urlQueryAllowed()
    }
}
    
extension NSURLSession {
    static var shared: NSURLSession {
        return NSURLSession.shared()
    }
}

extension NSURL {
    func deletingLastPathComponent() -> NSURL {
        return deletingPathExtension!
    }
}
#if os(Linux)
extension NSUUID {
    var uuidString: String {
        return UUIDString
    }
}
#endif

extension NSURLSessionConfiguration {
    static func defaultConfiguration() -> URLSessionConfiguration {
        return URLSessionConfiguration.default()
    }
}
#endif


extension Data {
    public var base64Encoded: String {
        return base64EncodedString(options: [])
    }
}

extension NSData {
    public var base64Encoded: String {
        return base64EncodedString(options: [])
    }
}




/*
extension Data {
    func base64EncodedString(options options: NSDataBase64EncodingOptions) -> String {
        return base64EncodedString(options)
    }
}
*/

/*
#if os(Linux)
    typealias Operation = NSOperation
    typealias PersonNameComponents = NSPersonNameComponents
    typealias FileManager = NSFileManager
    typealias URL = NSURL
    typealias URLSession = NSURLSession
    typealias URLSessionDelegate = NSURLSessionDelegate
    typealias URLRequest = NSURLRequest
    typealias DateFormatter = NSDateFormatter
    typealias Date = NSDate
    typealias SortDescriptor = NSSortDescriptor
    typealias URLSessionTask = NSURLSessionTask
    typealias URLSessionDataDelegate = NSURLSessionDataDelegate
    typealias URLSessionDownloadDelegate = NSURLSessionDownloadDelegate
    typealias URLSessionDownloadTask = NSURLSessionDownloadTask
    
    typealias URLSessionConfiguration = NSURLSessionConfiguration
    typealias OperationQueue = NSOperationQueue
    typealias Predicate = NSPredicate
    
    extension NSFileManager {
        var `default`: NSFileManager {
            return NSFileManager.default()
        }
    }
    
    extension NSUUID {
        var uuidString: String {
            return UUIDString
        }
    }
    
    
#endif

*/
