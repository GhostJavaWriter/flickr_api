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
        
        do {
            
            let imageData = try Data(contentsOf: url)
            
            if isCancelled {
                return
            }
            
            guard !imageData.isEmpty else {
                photoRecord.state = .failed
                photoRecord.image = UIImage(named: "errorImagePlaceholder")
                NSLog(NetworkError.noData.localizedDescription)
                return
            }
            
            photoRecord.image = UIImage(data:imageData)
            photoRecord.state = .downloaded
            
        } catch {
            photoRecord.state = .failed
            photoRecord.image = UIImage(named: "errorImagePlaceholder")
            NSLog(error.localizedDescription)
        }
    }
}

