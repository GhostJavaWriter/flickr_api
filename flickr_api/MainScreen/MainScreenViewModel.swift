//
//  MainScreenViewModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

final class MainScreenViewModel {
    
    private var networkManager: NetworkManager
    
    private var resources: [ItemViewModel] = [] {
        didSet {
            updateImagesCollectionView?()
        }
    }
    private var searchHistoryItems: [String] = [] {
        didSet {
            updateSearchHistory?()
        }
    }
    
    var updateSearchHistory: (() -> Void)?
    var updateImagesCollectionView: (() -> Void)?
    var setupFooterIndicatorView: ((LoadingReusableView) -> Void)?
    
    private var currentPage = 1
    private var totalPages = 1
    private var currentSearchText: String?
    private(set) var isLoading = false
    
    private let searchHistoryKey = "history"
    
    // MARK: - Init
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        retriveSearchHistory()
    }
    
    // MARK: - CollectionViewDataSource
    
    /// Returns number of image models in resources that loaded from network
    func numberOfImageModels() -> Int {
        resources.count
    }
    
    /// Returns specified image model from resources that loaded from network
    func imageModelAtIndexPath(_ indexPath: IndexPath) -> ItemViewModel {
        resources[indexPath.row]
    }
    
    // MARK: - SearchTableViewDataSource
    
    /// Returns number of items in search history
    func numberOfSearchItems() -> Int {
        searchHistoryItems.count
    }
    
    /// Returns specified searched text at indexPath from search history
    func searchItemAt(_ indexPath: IndexPath) -> String {
        searchHistoryItems[indexPath.row]
    }
    
    /// Saves searched text in UserDefaults
    func saveSearch(_ searchText: String) {
        searchHistoryItems.append(searchText)
        UserDefaults.standard.set(searchHistoryItems, forKey: searchHistoryKey)
    }
    
    private func retriveSearchHistory() {
        if let items = UserDefaults.standard.stringArray(forKey: searchHistoryKey) {
            searchHistoryItems = items
        } else {
            UserDefaults.standard.set(searchHistoryItems, forKey: searchHistoryKey)
        }
    }
    
    // MARK: - Network call
    
    /// Loads and appends new data from the next page
    func loadMoreData() {
        guard !isLoading else { return }
        guard currentPage <= totalPages else { return }
        
        getImages(searchText: currentSearchText, page: currentPage) { [weak self] model in
            
            guard let self = self else { return }
            let result = processLoadedData(model: model)
            self.resources.append(contentsOf: result)
        }
    }
    
    /// Loads and assigns new data from request with specified search text
    func newSearch(_ searchText: String?, completion: (() -> Void)?) {
        currentSearchText = searchText
        saveSearch(searchText ?? "")
        currentPage = 1
        
        getImages(searchText: searchText) { [weak self] model in
            
            guard let self = self else { return }
            let result = processLoadedData(model: model)
            self.resources = result
            completion?()
        }
    }
    
    private func processLoadedData(model: ResponseModel) -> [ItemViewModel] {
        
        var resources: [ItemViewModel] = []
        let photoModels = model.photos.photo

        for photoModel in photoModels {
            let photoRecord = PhotoRecord(imageModel: photoModel)
            let itemViewModel = ResourceViewModel(networkManager: networkManager, photoRecord: photoRecord)
            resources.append(itemViewModel)
        }
        
        totalPages = model.photos.pages
        currentPage += 1
        isLoading = false
        
        return resources
    }
    
    private func getImages(searchText: String?, page: Int = 1, completion: @escaping (ResponseModel) -> Void) {
        isLoading = true
        networkManager.retriveData(searchText: searchText,
                                     page: String(page))
        { (result: Result<ResponseModel, NetworkError>) in
            
            switch result {
            case .success(let model):
                completion(model)
            case .failure(let error):
                print(error.localizedDescription)
                // TODO: - handle error
            }
        }
    }
}
