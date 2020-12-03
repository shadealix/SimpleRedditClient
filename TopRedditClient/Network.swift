//
//  Network.swift
//  TopRedditClient
//
//  Created by Alix on 12/3/20.
//

import Foundation

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class APIClient {
    private let baseURL = ""
    
    static let shared: APIClient = .init()
    private init() {}
    
    private func perform<D:Decodable>(responseType: D.Type, request: URLRequest, session: URLSession = .shared, completion: @escaping (Result<D, Error>) -> ()) {
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let apiResponse = try JSONDecoder().decode(D.self, from: data)
                    completion(.success(apiResponse))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                //unknown error
            }
        }.resume()
    }
}
