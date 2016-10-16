import XCTest
@testable import OpenCloudKit

class OpenCloudKitTests: XCTestCase {
    
    let requestBodyString = "{\"zoneWide\":false,\"query\":{\"recordType\":\"Items\",\"filterBy\":[],\"sortBy\":[]}}"

    func pathForTests() -> String {
        let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
        return parent
    }
    
    func ECKeyPath() -> String {
        return "\(pathForTests())/Supporting/testeckey.pem"
    }
    
    func publicECKeyPath() -> String {
        return "\(pathForTests())/Supporting/eckey.pub"
    }
    
    func testSHA256() {
        let message = "test"
        let data = message.data(using: String.Encoding.utf8)!
        let resultHash = data.sha256().base64EncodedString(options: [])
        let testSHA256Hash = "n4bQgYhMfWWaL+qgxVrQFaO/TxsrC4Is0V1sFbDwCgg="
        XCTAssertEqual(resultHash, testSHA256Hash)
    }
    
    func testVerifySignedData() {
        
        let evpKey = try! EVPKey(contentsOfFile: publicECKeyPath(), type: EVPKeyType.Public)
        let data = try! Data(contentsOf: URL(fileURLWithPath: "\(pathForTests())/Supporting/test.txt"))
        
        let signedBase64 = "MEUCIQCa5vSe3xRHpN4FuUeNeNNB7gHpexMN1RYal4wJCpHExAIgdi/IV/K88aeIzoM0YaWp4PkX9T1+1oZNKZQY679uqRk="
        let signedData = Data(base64Encoded: signedBase64, options: [])!
        
        let context = try! MessageVerifyContext(try! MessageDigest("sha256WithRSAEncryption"), withKey: evpKey)
        try! context.update(data: data as NSData)
        
        XCTAssert(context.verify(signature: signedData as NSData), "Signature should verify successfully")
        
    }

    func testRawPayload() {
        
        let requestDate = "2016-07-13T03:16:51Z"
        let urlPath = "/database/1/iCloud.benjamin.CloudTest/development/public/records/query"
        let requestBody =  requestBodyString.data(using: String.Encoding.utf8)!
        
        // Should Equal 0sdWcosXLRqAQp9TQ4LzZOTgiETnGpqlODfsnN9Cqr0=
        let requestBodyHash = requestBody.sha256().base64EncodedString(options: [])
        
        let rawPayload = CKServerRequestAuth.rawPayload(withRequestDate: requestDate, requestBody: requestBody as NSData, urlSubpath: urlPath)
        
        let expectedPayload = "\(requestDate):\(requestBodyHash):\(urlPath)"
        XCTAssertEqual(rawPayload, expectedPayload)
        
    }
    
    func testSignWithPrivateKey() {
        
        let requestBody = requestBodyString.data(using: String.Encoding.utf8)!
        let signedData = CKServerRequestAuth.sign(data: requestBody as NSData, privateKeyPath: ECKeyPath())
        XCTAssertNotNil(signedData)
        
        //TODO: Verify the signature is correct
        
    }
    
    /*
    func testValidSignature() {
        
        let requestDate = "2016-07-13T03:16:51Z"
        let urlPath = "/database/1/iCloud.benjamin.CloudTest/development/public/records/query"
        let requestBody = NSData(data: requestBodyString.data(using: String.Encoding.utf8)!)

        let requestAuth = CKServerRequestAuth(requestBody: requestBody, urlPath: urlPath, privateKeyPath: ECKeyPath())!
        let signature = NSData(base64Encoded: requestAuth.signature, options: [])!

        
        // Verify signature
        let rawPayload = CKServerRequestAuth.rawPayload(withRequestDate: requestDate, requestBody: requestBody, urlSubpath: urlPath)
        let payload = rawPayload.data(using: String.Encoding.utf8)! as NSData
        
        let publicKey = try! EVPKey(contentsOfFile: publicECKeyPath(), type: EVPKeyType.Public)
        let context = try! MessageVerifyContext(try! MessageDigest("sha256WithRSAEncryption"), withKey: publicKey)
        try! context.update(data: payload)
        
        XCTAssert(context.verify(signature: signature), "Signature should verify successfully")
    }
 */
    func testAuthenicateServerWithURLRequest() {
        
        let url = URL(string: "https://api.apple-cloudkit.com/database/1/iCloud.benjamin.CloudTest/development/public/records/query")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody =  requestBodyString.data(using: String.Encoding.utf8)!
        
        let serverKeyID = "TEST_KEY"
        let ecKeyPath = ECKeyPath()
        
        let finalRequest = CKServerRequestAuth.authenticateServer(forRequest: urlRequest, serverKeyID: serverKeyID, privateKeyPath: ecKeyPath)
        
        if let finalRequest = finalRequest {
            XCTAssertEqual(finalRequest.allHTTPHeaderFields!["X-Apple-CloudKit-Request-KeyID"], serverKeyID)
            XCTAssertNotNil(finalRequest.allHTTPHeaderFields?["X-Apple-CloudKit-Request-ISO8601Date"])
            XCTAssertNotNil(finalRequest.allHTTPHeaderFields?["X-Apple-CloudKit-Request-SignatureV1"])
            
        } else {
            XCTAssertNotNil(finalRequest, "The returned URLRequest should not be nil, if the signing succeeded")
        }
    }
    

    

    static var allTests : [(String, (OpenCloudKitTests) -> () throws -> Void)] {
        return [
            ("testSHA256", testSHA256),
            ("testVerifySignedData", testVerifySignedData),
            ("testRawPayload", testRawPayload),
            ("testSignWithPrivateKey", testSignWithPrivateKey),
            ("testAuthenicateServerWithURLRequest", testAuthenicateServerWithURLRequest)
        ]
    }
}
