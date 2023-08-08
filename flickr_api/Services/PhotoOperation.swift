//
//  PhotoOperation.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 7.08.2023.
//

import UIKit

enum PhotoRecordState {
    case new, downloaded, failed
}

final class PhotoRecord {
    
    let imageModel: PhotoModel
    var state: PhotoRecordState = .new
    var image = UIImage(named: "placeHolderImage")
    
    init(imageModel: PhotoModel) {
        self.imageModel = imageModel
    }
}

final class PendingOperations {
    
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

final class ImageDownloader: Operation {
    
    let photoRecord: PhotoRecord
    
    init(_ photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        let model = photoRecord.imageModel
        let imageURLString = "https://farm\(model.farm).static.flickr.com/\(model.server)/\(model.id)_\(model.secret).jpg"
        
        guard let url = URL(string: imageURLString) else {
            // TODO: - handle error
            return
        }
        sleep(2)
        guard let imageData = try? Data(contentsOf: url) else {
            // TODO: - handle error
            return
        }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            photoRecord.image = UIImage(data:imageData)
            photoRecord.state = .downloaded
        } else {
            photoRecord.state = .failed
            photoRecord.image = UIImage(named: "placeHolderImage")
        }
    }
}

