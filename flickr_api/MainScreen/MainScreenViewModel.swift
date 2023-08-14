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
            updateUI?()
        }
    }
    
    var updateUI: (() -> Void)?
    var setupIndicatorView: ((LoadingReusableView) -> Void)?
    
    private var currentPage = 1
    private var totalPages = 1
    private var currentSearchText: String?
    private(set) var isLoading = false
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func numberOfItemsInSection() -> Int {
        resources.count
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> ItemViewModel {
        resources[indexPath.row]
    }
    
    func loadMoreData() {
        guard !isLoading else { return }
        guard currentPage <= totalPages else { return }
        
        getImages(searchText: currentSearchText, page: currentPage) { [weak self] model in
            
            guard let self = self else { return }
            let result = processLoadedData(model: model)
            self.resources.append(contentsOf: result)
        }
    }
    
    func newSearch(_ searchText: String?, completion: (() -> Void)?) {
        currentSearchText = searchText
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
        networkManager.getImagesWith(searchText: searchText,
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
