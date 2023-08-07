//
//  CollectionViewDataSource.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

final class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var viewModel: MainScreenViewModel
    
    init(viewModel: MainScreenViewModel) {
        self.viewModel = viewModel
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellViewModel.reuseIdentifier, for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        if let model = viewModel.itemAtIndexPath(indexPath) {
            
            let cellViewModel = CellViewModel(networkManager: viewModel.networkManager)
            cellViewModel.model = model
            cell.viewModel = cellViewModel
            cell.setUpdateImageObserver()
        } else {
            NSLog("photo model == nil")
        }
        
        return cell
    }
    
}
