//
//  Extension.swift
//  TopRedditClient
//
//  Created by Alix on 12/3/20.
//

import UIKit

extension URL {
    
    func addParams(params: [String: String]?) -> URL {
        guard let params = params, !params.isEmpty, var urlComp = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        urlComp.queryItems = queryItems
        guard let url = urlComp.url else {
            return self
        }
        return url
    }
}

extension DateFormatter {
    convenience init (format: String) {
        self.init()
        dateFormat = format
        locale = Locale.current
    }
}

extension String {
    func toDate(format: String) -> Date? {
        return DateFormatter(format: format).date(from: self)
    }
    
    func toDateString(inputFormat: String, outputFormat:String) -> String? {
        if let date = toDate(format: inputFormat) {
            return DateFormatter(format: outputFormat).string(from: date)
        }
        return nil
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension URLRequest {
    static func createRequest(baseUrl: String,
                              endPoint: String = "",
                              params: [String:String],
                              method: Method = .get, authToken: String? = nil) -> URLRequest? {
        guard let url = URL(string: baseUrl)?
            .addParams(params: params) else {
                return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let authToken = authToken {
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

extension UIViewController {
    func showAlert(title: String, message: String, okTitle: String = "Ok", cancelTitle: String = "Cancel", okAction: (() -> ())? = nil, cancelAction: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (_) in
            okAction?()
        }))
        if let cancelAction = cancelAction {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (_) in
                cancelAction()
            }))
        }
        present(alert, animated: true)
    }
}

enum RedditClientError: Error, LocalizedError {
    case urlCreatingFailed
    case imageNotExists
    case previewImageNotFound
    case previewImageNotEnabled
    
    var errorDescription: String? {
        switch self {
        case .imageNotExists: return "Image not exists"
        case .previewImageNotFound: return "Preview image not found"
        case .urlCreatingFailed: return "Failed to create valid URL"
        case .previewImageNotEnabled: return "Preview image not enabled"
        }
    }
}

extension UIImage {
    convenience init?(assets: Assets.Images) {
        self.init(named: assets.rawValue)
    }
}
