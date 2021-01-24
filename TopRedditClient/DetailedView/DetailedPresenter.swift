//
//  DetailedPresenter.swift
//  TopRedditClient
//
//  Created by Alix on 1/23/21.
//

import UIKit

final class DetailedPresenter {
    
    private weak var view: DetailedViewController?
    private let utilityQueue: DispatchQueue = .global(qos: .utility)
    public var imageURLString: String
    
    init(view: DetailedViewController?, imageURLString: String) {
        self.view = view
        self.imageURLString = imageURLString
    }
    
    func getImage(imageManager: ImageManager = .shared) {
        view?.startActivityAnimating()
        utilityQueue.async {
            imageManager.image(by: self.imageURLString) { [weak self] (result) in
                self?.view?.stopActivityAnimating()
                switch result {
                case .success(let image):
                    self?.view?.setImage(image)
                case .failure(let error):
                    self?.view?.showError(error)
                }
            }
        }
    }
    
    func openPreferences() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
        }
    }
}
