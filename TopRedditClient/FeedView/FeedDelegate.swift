//
//  FeedDelegate.swift
//  TopRedditClient
//
//  Created by Alix on 12/8/20.
//

import UIKit

final class FeedDelegate: NSObject, UITableViewDelegate {
    
    private var tableView: UITableView
    private var presenter: FeedPresenter
    private var mainQueue: DispatchQueue = .main
    
    init(tableView: UITableView, presenter: FeedPresenter) {
        self.presenter = presenter
        self.tableView = tableView
        super.init()
        self.tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = presenter.items[indexPath.row]
        if let cell = cell as? ListingTableViewCell {
            presenter.image(by: item.thumbnail) { [weak self] (result) in
                switch result {
                case .success(let image):
                    self?.mainQueue.async {
                        cell.thumbnailImageView.image = image
                    }
                case .failure:
                    self?.mainQueue.async {
                        cell.thumbnailImageView.image = UIImage(assets: .noImage)
                    }
                }
            }
        }
        //if last element load more
        if indexPath.row == presenter.items.count - 1 {
            presenter.loadMore()
        }
    }
}
