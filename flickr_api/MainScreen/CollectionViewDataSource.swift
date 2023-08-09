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
        viewModel.numberOfItemsInSection()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = viewModel.itemAtIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.reuseIdentifier,
                                                      for: indexPath)
        
        model.setup(cell, in: collectionView, at: indexPath)
        
        return cell
    }
    
}
