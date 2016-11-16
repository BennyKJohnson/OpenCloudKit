//
//  CKWebRequest.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 6/07/2016.
//
//

import Foundation

class CKWebRequest {

    var currentWebAuthToken: String?
    
    let containerConfig: CKContainerConfig
    
    init(containerConfig: CKContainerConfig) {
        self.containerConfig = containerConfig
    }
    
    convenience init(container: CKContainer) {
        self.init(containerConfig: CloudKit.shared.containerConfig(forContainer: container)!)
    }
    
    var authQueryItems: [URLQueryItem]? {
        
        if let apiTokenAuth = containerConfig.apiTokenAuth {
            var queryItems: [URLQueryItem] = []

            let apiTokenQueryItem = URLQueryItem(name: "ckAPIToken", value: apiTokenAuth)
            queryItems.append(apiTokenQueryItem)
            
            
            if let currentWebAuthToken = currentWebAuthToken {
                let webAuthTokenQueryItem = URLQueryItem(name: "ckWebAuthToken", value: currentWebAuthToken)
                queryItems.append(webAuthTokenQueryItem)
            }
            
            return queryItems
        } else {
            return nil
        }
    }
    
    var serverToServerKeyAuth: CKServerToServerKeyAuth? {
        return containerConfig.serverToServerKeyAuth
    }
    /*
    func ckError(forNetworkError networkError: Error) -> NSError {
        
        let networkError = networkError as NSError
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
    */
    func ckError(forServerResponseDictionary dictionary: [String: AnyObject]) -> NSError {
        if let recordFetchError = CKRecordFetchErrorDictionary(dictionary: dictionary) {
            
            let errorCode = CKErrorCode.errorCode(serverError: recordFetchError.serverErrorCode)!
            
            var userInfo: NSErrorUserInfoType  = [:]
         
            userInfo["redirectURL"] = recordFetchError.redirectURL
            userInfo[NSLocalizedDescriptionKey] = recordFetchError.reason
            
            userInfo[CKErrorRetryAfterKey] = recordFetchError.retryAfter
            userInfo["uuid"] = recordFetchError.uuid

            return NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: userInfo)
            
        } else {
            
           
            return NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: NSErrorUserInfoType())
        }
    }

    func perform(request: URLRequest, completionHandler: @escaping ([String: Any]?, Error?) -> Void) -> URLSessionTask? {
        
        let session = URLSession.shared
       
        let requestCompletionHandler:  (Data?, URLResponse?, Error?) -> Swift.Void = { (data, response, networkError) in
            if let networkError = networkError {
                
              //  let error = self.ckError(forNetworkError: networkError)
                completionHandler(nil, networkError)
                
            } else if let data = data {
                
                
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print(dataString as Any)
                let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        // Error Occurred
                        let error = self.ckError(forServerResponseDictionary: dictionary)
                        completionHandler(nil, error)
                        
                    } else {
                        completionHandler(dictionary, nil)
                    }
                }
                
            }
            
        }
        #if os(Linux)
            let task = session.dataTask(with: request)
        #else
            let task = session.dataTask(with: request, completionHandler: requestCompletionHandler)
        #endif
        
        task.resume()
        
        return task
    }
    
    func urlRequest(with url: URL, parameters: [String: AnyObject]? = nil) -> URLRequest? {
        // Build URL
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
       
        components?.queryItems = authQueryItems
        print(components?.path as Any)
        guard let requestURL = components?.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: requestURL)
        if let parameters = parameters {
            
            #if os(Linux)
                let jsonData: Data = try! JSONSerialization.data(withJSONObject: parameters.bridge(), options: [])
            #else
                let jsonData: Data = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            #endif
            
            urlRequest.httpBody = jsonData
            urlRequest.httpMethod = "POST"
        } else {
            let jsonData: Data = try! JSONSerialization.data(withJSONObject: NSDictionary(), options: [])
            urlRequest.httpBody = jsonData
            urlRequest.httpMethod = "GET"
        }
        
        if let serverToServerKeyAuth = serverToServerKeyAuth {
            if let signedRequest  = CKServerRequestAuth.authenicateServer(forRequest: urlRequest, withServerToServerKeyAuth: serverToServerKeyAuth) {
                urlRequest = signedRequest
            }
        }
        
        return urlRequest
    }

    
    func request(withURL url: String, completetion: @escaping ([String: Any]?, Error?) -> Void) -> URLSessionTask? {
       
        // Build URL
        var components = URLComponents(string: url)
        components?.queryItems = authQueryItems
        print(components?.path as Any)
        guard let requestURL = components?.url else {
            return nil
        }
        
        let jsonData: Data = try! JSONSerialization.data(withJSONObject: NSDictionary(), options: [])
        var urlRequest = URLRequest(url: requestURL)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        
        return perform(request: urlRequest, completionHandler: completetion)
    }
    
    
    func request(withURL url: String, parameters: [String: Any]?, completetion: @escaping ([String: Any]?, Error?) -> Void) -> URLSessionTask? {
        
        // Build URL
        var components = URLComponents(string: url)
        components?.queryItems = authQueryItems
        print(components?.path as Any)
        guard let requestURL = components?.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: requestURL)
        if let parameters = parameters {
            
            #if os(Linux)
            let jsonData: Data = try! JSONSerialization.data(withJSONObject: parameters.bridge(), options: [])
            #else
            let jsonData: Data = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            #endif
            
            urlRequest.httpBody = jsonData
            urlRequest.httpMethod = "POST"
        } else {
            let jsonData: Data = try! JSONSerialization.data(withJSONObject: NSDictionary(), options: [])
            urlRequest.httpBody = jsonData
            urlRequest.httpMethod = "GET"
        }
        
        urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        if let serverToServerKeyAuth = serverToServerKeyAuth {
            if let signedRequest  = CKServerRequestAuth.authenicateServer(forRequest: urlRequest, withServerToServerKeyAuth: serverToServerKeyAuth) {
                urlRequest = signedRequest
            }
        }
        
        return perform(request: urlRequest, completionHandler: completetion)
    }
    
    
    
}
