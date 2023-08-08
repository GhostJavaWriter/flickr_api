//
//  CellViewModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

final class CellViewModel {
    
    static let reuseIdentifier = String(describing: CollectionViewCell.self)
    
    var updateCell: (() -> Void)?
    
    let photoRecord: PhotoRecord
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    

}
