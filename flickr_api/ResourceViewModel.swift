//
//  ResourceViewModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

protocol ItemViewModel {
    
    var reuseIdentifier: String { get }
    
    func setup(_ cell: UICollectionReusableView,
               in collectionView: UICollectionView,
               at indexPath: IndexPath)
}

protocol ResourceCell {
    
    func setupResource(image: UIImage)
}

struct ResourceViewModel: ItemViewModel {
    
    var reuseIdentifier = String(describing: CollectionViewCell.self)
    
    let networkManager: NetworkManager
    let photoRecord: PhotoRecord
    
    func setup(_ cell: UICollectionReusableView,
               in collectionView: UICollectionView,
               at indexPath: IndexPath) {
        
        networkManager.addLoadOperation(photoRecord: photoRecord, at: indexPath) {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ResourceCell else {
                NSLog("cell error")
                return
            }
            
            guard let image = photoRecord.image else {
                NSLog("image == nil")
                return
            }
            
            cell.setupResource(image: image)
        }
    }
}
