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
    public var perAssetCompletionBlock: ((CKAsset, Error?) -> Swift.Void)?

    public var downloadAssetsCompletionBlock: (([CKAsset], Error?) -> Swift.Void)?
    
    public var downloadedAssets: [CKAsset] = []
    
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
        #if !os(Linux)
        downloadSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        #endif
        
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
        super.cancel()
        
        downloadSession?.invalidateAndCancel()
    }
    
    override func performCKOperation() {
        prepareForDownload()
        
        download()
    }
    
    override func finishOnCallbackQueue(error: Error?) {
        
        if(error == nil){
            // todo create partial error from assetErrors array, see modify records
        }
        
        downloadAssetsCompletionBlock?(assetsToDownload, error)
        
        super.finishOnCallbackQueue(error: error)
    }
    
    func progressed(asset: CKAsset, progress: Double){
        callbackQueue.async {
            self.perAssetProgressBlock?(asset, progress)
        }
    }
    
    func completed(asset: CKAsset, error: Error?){
        callbackQueue.async {
            self.perAssetCompletionBlock?(asset, error)
        }
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

#if !os(Linux)
extension CKDownloadAssetsOperation: URLSessionDownloadDelegate {
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        
        guard let currentAsset = assetsByDownloadTask[downloadTask] else {
            fatalError("Asset should belong to completed download task")
        }
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        // Call Progress Block
        progressed(asset: currentAsset, progress: progress)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let downloadTask = task as! URLSessionDownloadTask
        
        print(task.currentRequest?.url?.absoluteString as Any)
        guard let currentAsset = assetsByDownloadTask[downloadTask] else {
            fatalError("Asset should belong to completed download task")
        }
        
        if let error = error {
            completed(asset: currentAsset, error: error)
            
            // todo add to assetErrors array
        }
        
        assetsByDownloadTask[downloadTask] = nil
        
        self.downloadedAssets.append(currentAsset)
        
        // If all task complete
        if assetsByDownloadTask.count == 0 {
            finish(error: nil)
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
                completed(asset: currentAsset, error: error)
                return
            }
            
            // Modifiy the CKAsset file URL
            currentAsset.fileURL = destinationURL as NSURL
            
            // Call perAssetCompleteBlock
            completed(asset: currentAsset, error: nil)
    }
 }
#endif
