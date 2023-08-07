//
//  MainScreenViewModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import Foundation

final class MainScreenViewModel {
    
    var networkManager: NetworkManager
    private var photos: [PhotoModel]? {
        didSet {
            updateUI?()
        }
    }
    var updateUI: (() -> Void)?
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        loadData()
    }
    
    func numberOfItemsInSection() -> Int {
        photos?.count ?? 0
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> PhotoModel? {
        return photos?[indexPath.row]
    }
    
    private func loadData() {
        networkManager.getPhotos(searchText: "kitties") { result in
            switch result {
            case .success(let model): self.photos = model.photos.photo
            case .failure(let error): print(error.localizedDescription) // show error view message
            }
        }
    }
}
