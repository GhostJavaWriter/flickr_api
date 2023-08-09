//
//  NetworkManager.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case timeoutError
    case invalidURL
    case invalidResponse
    case invalidAPIKey
}

final class NetworkManager {
    
    private let pendingOperations = PendingOperations()
    
    func addLoadOperation(photoRecord: PhotoRecord,
                          at indexPath: IndexPath,
                          completion: @escaping (() -> Void)) {
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        
        let downloader = ImageDownloader(photoRecord)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                completion()
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func getImagesWith<T: Codable>(of type: T.Type, searchText: String?,
                       completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let request = getRequest(searchText) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.transportError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let result = try self.decodeFromJSON(data: data, type: T.self)
                completion(.success(result))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    private func decodeFromJSON<T: Codable>(data: Data, type: T.Type) throws -> T {
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    private func getRequest(_ searchText: String?) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        
        components.queryItems = [
            URLQueryItem(name: "method", value: Constants.SearchRequest.method),
            URLQueryItem(name: "api_key", value: Constants.SearchRequest.apiKey),
            URLQueryItem(name: "format", value: Constants.SearchRequest.format),
            URLQueryItem(name: "text", value: searchText ?? Constants.SearchRequest.defaultText),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "per_page", value: "20")
        ]
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request
    }
}
