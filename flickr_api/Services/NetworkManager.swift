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
    
    func getImagesWith(searchText: String?,
                   completion: @escaping (Result<ResponseModel, NetworkError>) -> Void) {
        
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
                let result = try self.decodeFromJSON(data: data, type: ResponseModel.self)
                completion(.success(result))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    func loadImage(from url: URL,
                   completion: @escaping (Result<UIImage?, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
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
            
            completion(.success(UIImage(data: data)))
            
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
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request
    }
}
