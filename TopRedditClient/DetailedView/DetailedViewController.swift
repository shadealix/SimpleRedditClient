//
//  DetailedViewController.swift
//  TopRedditClient
//
//  Created by Alix on 12/26/20.
//

import UIKit

final class DetailedViewController: UIViewController {
    
    @IBOutlet weak var detailedImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public var presenter: DetailedPresenter?
    private let mainQueue: DispatchQueue = .main
    private let urlEncodingKey = "urlEncodingKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.getImage()
        navigationItem.rightBarButtonItem = .init(title: "Save", style: .plain, target: self, action: #selector(saveImage))
    }
    
    func startActivityAnimating() {
        mainQueue.async {
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }
    }
    
    func stopActivityAnimating() {
        mainQueue.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setImage(_ image: UIImage) {
        mainQueue.async {
            self.detailedImageView.image = image
        }
    }
    
    func showError(_ error: Error) {
        mainQueue.async {
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    override func applicationFinishedRestoringState() {
        super.applicationFinishedRestoringState()
        if presenter != nil {
            presenter?.getImage()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let imageUrlString = coder.decodeObject(forKey: urlEncodingKey) as? String {
            self.presenter = .init(view: self, imageURLString: imageUrlString)
        } else {
            //nothing to restore
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        if let imageURL = presenter?.imageURLString {
            coder.encode(imageURL, forKey: urlEncodingKey)
        }
    }
    
    @objc private func saveImage() {
        mainQueue.async {
            guard let image = self.detailedImageView.image else {
                self.showError(RedditClientError.imageNotExists)
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.showSavedMessage(image:error:contextInfo:)), nil)
        }
    }
    
    @objc private func showSavedMessage(image: UIImage, error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        mainQueue.async {
            if error == nil {
                self.showAlert(title: "Photo saved!", message: "")
            } else {
                self.showNeedPhotosAccessMessage()
            }
        }
    }
    
    private func showNeedPhotosAccessMessage() {
        self.showAlert(title: "Error", message: "Adding photos not permited. Please open preferences", okTitle: "Open preferences") {
            
        } cancelAction: {  }
    }
}
