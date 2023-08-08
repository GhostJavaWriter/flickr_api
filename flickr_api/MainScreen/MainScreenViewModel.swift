//
//  MainScreenViewModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

final class MainScreenViewModel: NSObject {
    
    var networkManager: NetworkManager
    
    private var images: [PhotoRecord] = [] {
        didSet {
            updateUI?()
        }
    }
    
    let pendingOperations = PendingOperations()
    
    var updateUI: (() -> Void)?
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        super.init()
        getImagesWith(searchText: nil)
    }
    
    func numberOfItemsInSection() -> Int {
        images.count
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> PhotoRecord {
        images[indexPath.row]
    }
    
    private func getImagesWith(searchText: String?) {
        networkManager.getImagesWith(searchText: searchText) { result in
            switch result {
            case .success(let model):
                var images: [PhotoRecord] = []
                for imageModel in model.photos.photo {
                    images.append(PhotoRecord(imageModel: imageModel))
                }
                self.images = images
            case .failure(let error): print(error.localizedDescription)
                // TODO: - handle error
            }
        }
    }
}

extension MainScreenViewModel: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            NSLog("searchBar.text == nil")
            return
        }
        
        if searchText != "" {
            getImagesWith(searchText: searchText)
        } else {
            getImagesWith(searchText: nil)
        }
    }
    
    
}
