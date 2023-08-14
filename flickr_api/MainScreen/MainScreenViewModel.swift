//
//  MainScreenViewModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

final class MainScreenViewModel: NSObject {
    
    private var networkManager: NetworkManager
    
    private var resources: [ItemViewModel] = [] {
        didSet {
            updateUI?()
        }
    }
    
    var updateUI: (() -> Void)?
    var setupIndicatorView: ((LoadingReusableView) -> Void)?
    
    private var currentPage = 1
    private var totalPages = 1
    private var currentSearchText: String?
    private(set) var isLoading = false
    var loadingIndicatorShouldAnimate: Bool {
        !isLoading && !resources.isEmpty
    }
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        super.init()
    }
    
    func numberOfItemsInSection() -> Int {
        resources.count
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> ItemViewModel {
        resources[indexPath.row]
    }
    
    func loadNextPage() {
        guard !isLoading else { return }
        guard currentPage <= totalPages else { return }
        
        isLoading = true
        
        getImagesWith(searchText: currentSearchText, page: currentPage)
    }
    
    private func getImagesWith(searchText: String?, page: Int = 1) {
        
        networkManager.getImagesWith(searchText: searchText,
                                     page: String(page))
        { [weak self] (result: Result<ResponseModel, NetworkError>) in
            
            guard let self = self else { return }
            switch result {
            case .success(let model):
                self.totalPages = model.photos.pages
                
                var resources: [ItemViewModel] = []
                let photoModels = model.photos.photo
                
                for photoModel in photoModels {
                    let photoRecord = PhotoRecord(imageModel: photoModel)
                    let itemViewModel = ResourceViewModel(networkManager: self.networkManager, photoRecord: photoRecord)
                    resources.append(itemViewModel)
                }
                self.currentPage += 1
                self.resources.append(contentsOf: resources)
                self.isLoading = false
                
            case .failure(let error):
                print(error.localizedDescription)
                // TODO: - handle error
            }
        }
    }
}

extension MainScreenViewModel: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            NSLog("searchBar.text == nil")
            return
        }
        
        if searchText != "" {
            currentSearchText = searchText
            currentPage = 1
            getImagesWith(searchText: searchText)
        } else {
            getImagesWith(searchText: nil)
        }
    }
    
}
