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
        
        let photoRecord = viewModel.itemAtIndexPath(indexPath)
        
        let cellViewModel = CellViewModel(photoRecord: photoRecord)
        cell.viewModel = cellViewModel
        
        switch photoRecord.state {
        case .failed: print("failed")
        case .new, .downloaded: startDownload(cellViewModel: cellViewModel, at: indexPath)
        }
        
        return cell
    }
    
    
    private func startDownload(cellViewModel: CellViewModel, at indexPath: IndexPath) {
        
        guard viewModel.pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        
        let downloader = ImageDownloader(cellViewModel.photoRecord)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.viewModel.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                cellViewModel.updateCell?()
                
            }
        }
        
        viewModel.pendingOperations.downloadsInProgress[indexPath] = downloader
        viewModel.pendingOperations.downloadQueue.addOperation(downloader)
    }
    
}
