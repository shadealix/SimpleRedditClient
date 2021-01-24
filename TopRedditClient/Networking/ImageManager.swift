//
//  ImageManager.swift
//  TopRedditClient
//
//  Created by Alix on 1/24/21.
//

import UIKit

final class ImageManager {
    
    static let shared: ImageManager = .init()
    private let imageCache = NSCache<NSString, UIImage>()
    
    private init() {
        imageCache.countLimit = 100
        imageCache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func image(by imageURLString: String, apiClient: APIClient = .shared, completion: @escaping ((Result<UIImage, Error>) -> ())) {
        if let cashedImage = imageCache.object(forKey: imageURLString as NSString) {
            completion(.success(cashedImage))
        } else {
            apiClient.downloadImage(imageURLString: imageURLString) { [weak self] (result) in
                switch result {
                case .success(let image):
                    self?.imageCache.setObject(image, forKey: imageURLString as NSString)
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

