//
//  CKDownloadAssetsOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 16/07/2016.
//
//

import Foundation

public class CKDownloadAssetsOperation: CKDatabaseOperation {
    
    let assetsToDownload: [CKAsset]
    
    var assetsByDownloadTask:[URLSessionDownloadTask: CKAsset] = [:]
    
    public var perAssetProgressBlock: ((CKAsset, Double) -> Swift.Void)?
    
    /* Called on success or failure for each record. */
    public var perAssetCompletionBlock: ((CKAsset, NSError?) -> Swift.Void)?

    public var downloadAssetsCompletionBlock: (([CKAsset], NSError?) -> Swift.Void)?
    
    var downloadSession: URLSession?
    
    public init(assetsToDownload: [CKAsset]) {
        
        self.assetsToDownload = assetsToDownload
        super.init()

    }
    
    func download() {
        for downloadTask in assetsByDownloadTask.keys {
            downloadTask.resume()
        }
    }
    
    func prepareForDownload() {
        
        downloadSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        if let downloadSession = downloadSession {
            
            // Create URLSessionDownloadTasks
            for asset in assetsToDownload {
                if let downloadURL = asset.downloadURL {
                    print("URL: \(downloadURL.absoluteString)")
                    // Create request for download URL
                    let downloadRequest = URLRequest(url: downloadURL)
                    // Create download task
                    let downloadTask = downloadSession.downloadTask(with: downloadRequest)
                    
                    // Add to dictionary
                    assetsByDownloadTask[downloadTask] = asset
                    
                }
            }

        }
    }
    
    override public func cancel() {
        downloadSession?.invalidateAndCancel()
    }
    
    override func performCKOperation() {
        prepareForDownload()
        
       download()
    }
}

extension CKDownloadAssetsOperation {
   public convenience init(records: [CKRecord]) {
        
        var assets: [CKAsset] = []
        for record in records {
            for key in record.allKeys() {
                if let asset = record[key] as? CKAsset {
                    assets.append(asset)
                }
            }
        }
        
        self.init(assetsToDownload: assets)
    }
}

extension CKDownloadAssetsOperation: URLSessionDownloadDelegate {
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        
        guard let currentAsset = assetsByDownloadTask[downloadTask] else {
            fatalError("Asset should belong to completed download task")
        }
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        // Call Progress Block
        perAssetProgressBlock?(currentAsset, progress)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        let downloadTask = task as! URLSessionDownloadTask
        
        print(task.currentRequest?.url?.absoluteString)
        guard let currentAsset = assetsByDownloadTask[downloadTask] else {
            fatalError("Asset should belong to completed download task")
        }
        
        if let error = error {
            perAssetCompletionBlock?(currentAsset, error)
        }
        
        assetsByDownloadTask[downloadTask] = nil
        
        // If all task complete
        if assetsByDownloadTask.count == 0 {
            // Call Completion Block
            downloadAssetsCompletionBlock?(assetsToDownload, nil)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let currentAsset = assetsByDownloadTask[downloadTask] else {
            fatalError("Asset should belong to completed download task")
        }
        
            // Save file to temporary Assets location
            let temporaryDirectory = NSTemporaryDirectory()
            let filename = NSUUID().uuidString
            let destinationURL = URL(fileURLWithPath: "\(temporaryDirectory)\(filename)")
            
            print(destinationURL)
            
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: destinationURL)
            } catch {}
            
            do {
                try fileManager.copyItem(at: location, to: destinationURL)
            } catch let error as NSError {
                print("Could not copy downloaded asset file to disk: \(error.localizedDescription)")
                perAssetCompletionBlock?(currentAsset, error)
                return
            }
            
            // Modifiy the CKAsset file URL
            currentAsset.fileURL = destinationURL
            
            // Call perAssetCompleteBlock
            perAssetCompletionBlock?(currentAsset, nil)
  
    }

}
