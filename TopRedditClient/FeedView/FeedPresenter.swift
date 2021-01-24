//
//  FeedPresenter.swift
//  TopRedditClient
//
//  Created by Alix on 12/8/20.
//

import UIKit

final class FeedPresenter {
    
    private weak var view: FeedViewController?
    
    private(set) var items: [ChildData] = []
    private var after: String?
    private var isLoading = false
    
    init(view: FeedViewController) {
        self.view = view
    }
    
    func getFeed(apiClient: APIClient = .shared, forceRefresh: Bool = false) {
        guard items.isEmpty || forceRefresh else {
            return
        }
        isLoading = true
        if items.isEmpty {
            view?.startActivitiIndicator()
        }
        apiClient.requestListing(count: 25, limit: 20) { [weak self] (result) in
            self?.view?.stoptActivitiIndicator()
            self?.isLoading = false
            switch result {
            case .success(let listing):
                self?.items = listing.listingInfo.children.map({ $0.data })
                self?.after = listing.listingInfo.after
                DispatchQueue.main.async {
                    self?.view?.reloadData()
                }
            case .failure(let error):
                self?.view?.showError(error)
            }
        }
    }
    
    func loadMore(apiClient: APIClient = .shared) {
        guard !isLoading else { return }
        isLoading = true
        apiClient.requestListing(count: 25, limit: 20, after: self.after) { [weak self] (result) in
            self?.isLoading = false
            guard let self = self else { return }
            switch result {
            case .success(let listing):
                guard listing.listingInfo.children.count > 0 else { return }
                let lastElementIndex = self.items.count
                let newItemsCount = listing.listingInfo.children.count
                let indexPathsToInsert: [IndexPath] = Array(lastElementIndex...(lastElementIndex + newItemsCount - 1)).map {
                    IndexPath(row: $0, section: 0)
                }
                self.after = listing.listingInfo.after
                self.items.append(contentsOf: listing.listingInfo.children.map({ $0.data }))
                DispatchQueue.main.async {
                    self.view?.insert(indexPaths: indexPathsToInsert)
                }
            case .failure(let error):
                self.view?.showError(error)
            }
        }
    }
    
    func saveFeed() {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileUrl = documentDirectoryUrl.appendingPathComponent("Feed.json")
        
            // Transform array into data and save it into file
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(items)
                try jsonData.write(to: fileUrl, options: [])
            } catch {
                #if DEBUG
                print(">>> error: \(error.localizedDescription)")
                #endif
            }
    }
    
    func restoreFeed() {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileUrl = documentDirectoryUrl.appendingPathComponent("Feed.json")
        
//        guard let stream = InputStream(url: fileUrl) else { return }
//           stream.open()
//           defer {
//                stream.close()
//           }
        
            do {
                let jsonData = try Data(contentsOf: fileUrl)
                let jsonDecoder = JSONDecoder()
                let items = try jsonDecoder.decode([ChildData].self, from: jsonData)
                self.items = items
            } catch {
                #if DEBUG
                print(">>> error: \(error.localizedDescription)")
                #endif
            }
    }
    
    func push(_ vc: UIViewController) {
        view?.push(vc)
    }
    
    func image(by imageURLString: String, imageManager: ImageManager = .shared, completion: @escaping ((Result<UIImage, Error>) -> ())) {
        imageManager.image(by: imageURLString, completion: completion)
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        guard items[indexPath.row].preview?.enabled ?? false else {
            view?.showError(RedditClientError.previewImageNotEnabled)
            return
        }
        let imageString = items[indexPath.row].preview?.images.first?.source.url ?? ""
        let urlString: String = imageString.replacingOccurrences(of: "&amp;", with: "&")
        let storyboard = UIStoryboard(name: StoryBoard.Main.storyboard, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: StoryBoard.Main.detailedViewController.rawValue) as? DetailedViewController else {
                view?.showError(RedditClientError.previewImageNotFound)
                return
        }
        let presenter = DetailedPresenter(view: vc, imageURLString: urlString)
        vc.presenter = presenter
        push(vc)
    }
}
