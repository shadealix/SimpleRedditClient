//
//  Network.swift
//  TopRedditClient
//
//  Created by Alix on 12/3/20.
//

import UIKit

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIURL: String {
    case oAuthURL = "https://oauth.reddit.com"
    case accessToken = "https://www.reddit.com/api/v1/access_token"
    case installedClient = "https://oauth.reddit.com/grants/installed_client"
}

enum APIURLEndpoints: String {
    case top = "top.json"
}

enum ListingTime: String {
    case all
    case hour
    case day
    case week
}

final class APIClient {
    
    static private let uuid = UUID().uuidString
    private var accessToken: AccessToken?
    private let utilityQueue: DispatchQueue = .global(qos: .utility)
    
    static let shared: APIClient = .init()
    private init() {}
    
    func requestToken(completion: @escaping (Result<AccessTokenResponse, Error>) -> ()) {
        
        let params = ["grant_type": APIURL.installedClient.rawValue, "device_id": "\(APIClient.uuid)"]
        
        guard var request = URLRequest.createRequest(baseUrl: APIURL.accessToken.rawValue, params: params, method: .post) else {
            completion(.failure(RedditClientError.urlCreatingFailed))
            return
        }
        let key = KeysInfoManager.productFor(named: .redditAppKey)
        let credentials = "\(key):"
        request.setValue("Basic \(credentials.toBase64())", forHTTPHeaderField: "Authorization")
        
        perform(request: request) { (result: Result<AccessTokenResponse, Error>) in
            switch result {
            case .success(let tokenResponse):
                self.accessToken = .init(token: tokenResponse.accessToken, expiresIn: tokenResponse.expiresIn)
                completion(.success(tokenResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestListing(count: Int, limit: Int, listingTime: ListingTime = .day, after: String? = nil, completion: @escaping (Result<Listing, Error>) -> ()) {
        var params = ["t": "\(listingTime.rawValue)", "count": "\(count)", "limit": "\(limit)"]
        if let after = after {
            params["after"] = after
        }
        
        self.getAccesToken { [weak self] (result) in
            switch result {
            case .success(let token):
                if let request = URLRequest.createRequest(baseUrl: "\(APIURL.oAuthURL.rawValue)/", endPoint: APIURLEndpoints.top.rawValue, params: params, method: .get, authToken: "bearer \(token)") {
                    self?.perform(request: request, completion: completion)
                } else {
                    completion(.failure(RedditClientError.urlCreatingFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getAccesToken(completion: @escaping ((Result<String, Error>) -> ())) {
        if let accessToken = accessToken, accessToken.isValid {
            completion(.success(accessToken.token))
        } else {
            requestToken { (result) in
                switch result {
                case .success(let response):
                    completion(.success(response.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func perform<D:Decodable>(request: URLRequest, session: URLSession = .shared, completion: @escaping (Result<D, Error>) -> ()) {
        utilityQueue.async {
            session.dataTask(with: request) { data, _, error in
                if let data = data {
                    do {
                        let apiResponse = try JSONDecoder().decode(D.self, from: data)
                        completion(.success(apiResponse))
                    } catch {
                        completion(.failure(error))
                    }
                }
                
                if let error = error {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    func downloadImage(imageURLString: String, session: URLSession = .shared, completion: @escaping (Result<UIImage, Error>) -> ()) {
        guard let imageURL = URL(string: imageURLString) else {
            completion(.failure(RedditClientError.urlCreatingFailed))
            return
        }
        utilityQueue.async {
            session.dataTask(with: imageURL, completionHandler: { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    completion(.success(image))
                }
                if let error = error {
                    completion(.failure(error))
                }
            }).resume()
        }
    }
}
