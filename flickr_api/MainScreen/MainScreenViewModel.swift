//
//  MainScreenViewModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

final class MainScreenViewModel: NSObject {
    
    var networkManager: NetworkManager
    
    private var resources: [ItemViewModel] = [] {
        didSet {
            updateUI?()
        }
    }
    
    var updateUI: (() -> Void)?
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        super.init()
        getImagesWith(searchText: nil)
    }
    
    func numberOfItemsInSection() -> Int {
        resources.count
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> ItemViewModel {
        resources[indexPath.row]
    }
    
    private func getImagesWith(searchText: String?) {
        networkManager.getImagesWith(of: ResponseModel.self, searchText: searchText) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let model):
                var resources: [ItemViewModel] = []
                let photoModels = model.photos.photo
                for photoModel in photoModels {
                    let photoRecord = PhotoRecord(imageModel: photoModel)
                    let itemViewModel = ResourceViewModel(networkManager: self.networkManager, photoRecord: photoRecord)
                    resources.append(itemViewModel)
                }
                self.resources = resources
                
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
