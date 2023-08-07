//
//  CellViewModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

final class CellViewModel {
    
    static let reuseIdentifier = String(describing: CollectionViewCell.self)
    
    var networkManager: NetworkManager
    var updateImage: ((UIImage?) -> Void)?
    var model: PhotoModel? {
        didSet {
            updateUI()
        }
    }
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        
    }
    
    private func updateUI() {
        
        if let model = model {
            let imageURLString = "https://farm\(model.farm).static.flickr.com/\(model.server)/\(model.id)_\(model.secret).jpg"
            
            if let imageURL = URL(string: imageURLString) {
                loadImage(from: imageURL)
            }
        } else {
            NSLog("model == nil")
        }
    }
    
    private func loadImage(from url: URL) {
        networkManager.loadImage(from: url) { result in
            switch result {
            case .success(let image): self.updateImage?(image)
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
}
