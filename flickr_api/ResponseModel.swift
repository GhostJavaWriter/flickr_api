//
//  ResponseModel.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import Foundation

struct ResponseModel: Codable {
    let photos: PhotosModel
    let stat: String
}

struct PhotosModel: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoModel]
}

struct PhotoModel: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
