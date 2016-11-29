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
    case error(CKError)
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
    
    var requestContentType: String = "application/json; charset=utf-8"
    
    var requestProperties:[String: AnyObject]?
    
    var urlSessionTask: URLSessionDataTask?
    
    var allowsAnonymousAccount = false
    
    var operationType: CKOperationRequestType = .records
    
    var metricsDelegate: CKURLRequestMetricsDelegate?
    
    var metrics: CKOperationMetrics?
    
    var completionBlock: ((CKURLRequestResult) -> ())?
    
    var request: URLRequest {
        get {
            var urlRequest = URLRequest(url: url)

            if let properties = requestProperties {
                
                let jsonData: Data = try! JSONSerialization.data(withJSONObject: properties, options: [])
                urlRequest.httpBody = jsonData
                urlRequest.httpMethod = "POST"
                urlRequest.addValue(requestContentType, forHTTPHeaderField: "Content-Type")
                
                let dataString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            
                CloudKit.debugPrint(dataString as Any)
               
                if let serverAccount = accountInfoProvider as? CKServerAccount {
                    // Sign Request 
                    if let signedRequest  = CKServerRequestAuth.authenicateServer(forRequest: urlRequest, withServerToServerKeyAuth: serverAccount.serverToServerAuth) {
                        urlRequest = signedRequest
                    }
                }
            
            } else {
                urlRequest.httpMethod = httpMethod

            }
          
        
            return urlRequest
        }
    }
    
    
    var sessionConfiguration: URLSessionConfiguration  {
        
        let configuration = URLSessionConfiguration.default
        
        return configuration
    }
    
    var url: URL {
        get {
            let accountInfo = accountInfoProvider ?? CloudKit.shared.defaultAccount!
        
            let baseURL =  accountInfo.containerInfo.publicCloudDBURL(databaseScope: databaseScope).appendingPathComponent("\(operationType)/\(path)")
            
            var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
            switch accountInfo.accountType {
            case .server:
                break
            case .anoymous, .primary:
                urlComponents.queryItems = []
                // if let accountInfo = accountInfoProvider {
                
                let apiTokenItem = URLQueryItem(name: "ckAPIToken", value: accountInfo.cloudKitAuthToken)
                urlComponents.queryItems?.append(apiTokenItem)
                
                if let icloudAuthToken = accountInfo.iCloudAuthToken {
                    
                    let webAuthTokenQueryItem = URLQueryItem(name: "ckWebAuthToken", value: icloudAuthToken)
                    urlComponents.queryItems?.append(webAuthTokenQueryItem)
                    
                }

                
            }
            
            // Perform Encoding
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of:"+", with: "%2B")
            CloudKit.debugPrint(urlComponents.url!)
            return urlComponents.url!
        }
    }
    
    func performRequest() {
        dateRequestWentOut = Date()
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)

        urlSessionTask = session.dataTask(with: request)
        urlSessionTask!.resume()
        
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
            CloudKit.debugPrint(jsonObject)
            
            
            // Call completion block
            if let error = CKErrorDictionary(dictionary: jsonObject) {
                completionBlock?(.error(CKError.server(jsonObject)))
            } else {
                let result = CKURLRequestResult.success(jsonObject)
                completionBlock?(result)
            }
        
        } catch let error as NSError {
            completionBlock?(.error(.parse(error)))
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        CloudKit.debugPrint(response)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        metrics = CKOperationMetrics(bytesDownloaded: 0, bytesUploaded: UInt(totalBytesSent), duration: 0, startDate: dateRequestWentOut!)
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error)
            // Handle Error
            completionBlock?(.error(.network(error)))
        }
    }
    

    
    
    
    
    
    
    
    
    
    
}

protocol CKAccountInfoProvider {
    var accountType: CKAccountType { get }
    var cloudKitAuthToken: String? { get }
    var iCloudAuthToken: String? { get }
    var containerInfo: CKContainerInfo { get }
}

struct CKServerInfo {
    static let path = "https://api.apple-cloudkit.com"
    
    static let version = "1"
}



