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
        viewModel.numberOfPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = viewModel.photoAtIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.defaultReuseIdentifier,
                                                      for: indexPath)
        
        model.setup(cell, in: collectionView, at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter,
           let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LoadingReusableView.defaultReuseIdentifier, for: indexPath) as? LoadingReusableView
        {
            viewModel.setupIndicatorView?(aFooterView)
            return aFooterView
        }
        return UICollectionReusableView()
    }
    
    
}
