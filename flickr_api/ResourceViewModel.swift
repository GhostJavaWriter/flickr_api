//
//  ResourceViewModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

protocol ItemViewModel {
    
    func setup(_ cell: UICollectionReusableView,
               in collectionView: UICollectionView,
               at indexPath: IndexPath)
}

struct ResourceViewModel: ItemViewModel {
    
    let networkManager: NetworkManager
    let photoRecord: PhotoRecord
    
    func setup(_ cell: UICollectionReusableView,
               in collectionView: UICollectionView,
               at indexPath: IndexPath) {
        
        guard let cell = cell as? ResourceCell else {
            NSLog("cell error(1)")
            return
        }
        guard let image = photoRecord.image else {
            NSLog("image == nil")
            return
        }
        
        cell.setupResource(image: image)
        
        switch photoRecord.state {
        case .downloaded:
            cell.stopAnimating()
            NSLog("downloaded")
        case .failed:
            cell.stopAnimating()
            NSLog("failed")
        case .new:
            cell.startAnimating()
            networkManager.addLoadOperation(photoRecord: photoRecord, at: indexPath) {
                
                guard let cell = collectionView.cellForItem(at: indexPath) as? ResourceCell else {
                    NSLog("cell error(2)")
                    return
                }
                
                DispatchQueue.main.async {
                    collectionView.reloadItems(at: [indexPath])
                    cell.stopAnimating()
                }
            }
        }
    }
}
