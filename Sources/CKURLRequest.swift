//
//  CKURLRequest.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 23/07/2016.
//
//

import Foundation

enum CKOperationRequestType: String {
    case records
    case assets
    case zones
    case users
    case lookup
    case subscriptions
    case tokens
}

enum CKURLRequestError {
    case JSONParse(NSError)
    case networkError(NSError)
}

enum CKURLRequestResult {
    case success([String: AnyObject])
    case error(NSError)
}

class CKURLRequest: NSObject {
    
    var accountInfoProvider: CKAccountInfoProvider?
    
    var isCancelled: Bool = false
    
    var databaseScope: CKDatabaseScope = .public

    var dateRequestWentOut: Date?
    
    var httpMethod: String = "GET"
    
    var isFinished: Bool = false
    
    var requiresSigniture: Bool = false
    
    var path: String = ""
    
    var requestContentType: String = ""
    
    var requestProperties:[String: AnyObject] = [:]
    
    var urlSessionTask: URLSessionDataTask?
    
    var allowsAnonymousAccount = false
    
    var operationType: CKOperationRequestType = .records
    
    var metricsDelegate: CKURLRequestMetricsDelegate?
    
    var metrics: CKOperationMetrics?
    
    var completionBlock: ((CKURLRequestResult) -> ())?
    
    var request: URLRequest {
        get {
            
            let jsonData: Data = try! JSONSerialization.data(withJSONObject: requestProperties, options: [])
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = httpMethod
            urlRequest.httpBody = jsonData
        
            return urlRequest
        }
    }
    
    
    var sessionConfiguration: URLSessionConfiguration  {
        
        var configuration = URLSessionConfiguration()
        
        return configuration
        
    }
    
    var url: URL {
        get {
            let baseURL = try! accountInfoProvider!.containerInfo.publicCloudDBURL.appendingPathComponent(path)
            
            var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = []
            if let accountInfo = accountInfoProvider {
                
                let apiTokenItem = URLQueryItem(name: "ckAPIToken", value: accountInfoProvider!.cloudKitAuthToken)
                urlComponents.queryItems?.append(apiTokenItem)
                
                if !allowsAnonymousAccount {
                    let webAuthTokenQueryItem = URLQueryItem(name: "ckWebAuthToken", value: accountInfo.iCloudAuthToken)
                    urlComponents.queryItems?.append(webAuthTokenQueryItem)
                    
                }
            }

            return urlComponents.url!
        }
    }
    
    func performRequest() {
        dateRequestWentOut = Date()
        let session = URLSession.shared
        urlSessionTask = session.dataTask(with: request)
        urlSessionTask?.resume()
        
    }
    
    func cancel() {
        isCancelled = true
    }
    
    func requestDidParseNodeFailure() {
        
    }
    
    func requestDidParseObject() {
        
    }
}

extension CKURLRequest: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if let operationMetrics = metrics {
            metrics?.bytesDownloaded = UInt(data.count)
            metricsDelegate?.requestDidFinish(withMetrics: operationMetrics)
        }
        
        // Parse JSON
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            
            // Call completion block
            let result = CKURLRequestResult.success(jsonObject)
            completionBlock?(result)
        } catch let error as NSError {
            completionBlock?(.error(error))
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Swift.Void) {
        
        
        
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        metrics = CKOperationMetrics(bytesDownloaded: 0, bytesUploaded: UInt(totalBytesSent), duration: 0, startDate: dateRequestWentOut!)
        
    }
}

protocol CKAccountInfoProvider {
    var cloudKitAuthToken: String { get }
    var iCloudAuthToken: String { get }
    var containerInfo: CKContainerInfo { get }
}

struct CKServerInfo {
    static let path = "https://api.apple-cloudkit.com"
    
    static let version = "1"
}



