//
//  CKWebRequest.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation

enum CKWebServiceAuth {
    case APIToken
    case webAuthToken
    case server
}



class CKWebRequest {
    
    static let shared = CKWebRequest()
    
    var currentAPIToken: String?
    
    var currentWebAuthToken: String?
    
    var serverKeyID: String!
    
    var privateKeyURL = "eckey.pem"
    
    let authType: CKWebServiceAuth = .server
    
    private init() {}
    
    var authQueryItems: [URLQueryItem]? {
        
        if authType == .server {
            return nil
        } else {
            
            var queryItems: [URLQueryItem] = []
            if let currentAPIToken = currentAPIToken  {
                let apiTokenQueryItem = URLQueryItem(name: "ckAPIToken", value: currentAPIToken)
                queryItems.append(apiTokenQueryItem)
            }
            
            if let currentWebAuthToken = currentWebAuthToken {
                let webAuthTokenQueryItem = URLQueryItem(name: "ckWebAuthToken", value: currentWebAuthToken)
                queryItems.append(webAuthTokenQueryItem)
            }
            
            return queryItems
        }
    }
    
    func ckError(forNetworkError networkError: NSError) -> NSError {
        let userInfo = networkError.userInfo
        let errorCode: CKErrorCode
        
        switch networkError.code {
        case NSURLErrorNotConnectedToInternet:
            errorCode = .NetworkUnavailable
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
            errorCode = .ServiceUnavailable
        default:
            errorCode = .NetworkFailure
        }
        
        let error = NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: userInfo)
        return error
    }
    
    func ckError(forServerResponseDictionary dictionary: [String: AnyObject]) -> NSError {
        if let recordFetchError = CKRecordFetchErrorDictionary(dictionary: dictionary) {
            
            let errorCode = CKErrorCode.errorCode(serverError: recordFetchError.serverErrorCode)!
            
            var userInfo:[ NSObject: AnyObject] = [:]
            
            userInfo["redirectURL"] = recordFetchError.redirectURL
            userInfo[NSLocalizedDescriptionKey] = recordFetchError.reason
            
            userInfo[CKErrorRetryAfterKey] = recordFetchError.retryAfter
            userInfo["uuid"] = recordFetchError.uuid

            return NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: userInfo)
            
        } else {
            return NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: [:])
        }
    }

    func request(withURL url: String, parameters: [String: AnyObject], completetion: ([String: AnyObject]?, NSError?) -> Void) -> URLSessionTask? {
        
        // Build URL
        var components = URLComponents(string: url)
        components?.queryItems = authQueryItems
        print(components?.path)
        guard let requestURL = components?.url else {
            return nil
        }
        
        let jsonData: Data = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        var urlRequest = URLRequest(url: requestURL)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        
        guard let request  = CKServerRequestAuth.authenticate(request: urlRequest, serverKeyID: serverKeyID, privateKeyPath: privateKeyURL) else {
            fatalError("Failed to sign request")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, networkError) in
            if let networkError = networkError {
                
                let error = self.ckError(forNetworkError: networkError)
                completetion(nil, error)
                
            } else if let data = data {
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print(dataString)
                let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        // Error Occurred
                        let error = self.ckError(forServerResponseDictionary: dictionary)
                        completetion(nil, error)
                        
                    } else {
                        completetion(dictionary, nil)
                    }
                }
                
            }
            
        }
      
        task.resume()
        
        return task
    }
    
    
    
}
