//
//  ViewController.swift
//  TopRedditClient
//
//  Created by Alix on 12/3/20.
//

import UIKit

final class FeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: FeedPresenter!
    private var feedDelegate: FeedDelegate!
    private var feedDatasource: FeedDatasource!
    private var mainQueue: DispatchQueue = .main
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = FeedPresenter(view: self)
        feedDelegate = FeedDelegate(tableView: tableView, presenter: presenter)
        feedDatasource = FeedDatasource(tableView: tableView, presenter: presenter)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = .init(frame: .zero)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        presenter.saveFeed()
        coder.encode(tableView.contentOffset.y, forKey: "tableView.contentOffset.y")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        presenter.restoreFeed()
        if let tableViewY = coder.decodeObject(forKey: "tableView.contentOffset.y") as? CGFloat {
            tableView.contentOffset.y = tableViewY
        }
    }
    
    override func applicationFinishedRestoringState() {
        super.applicationFinishedRestoringState()
        #if DEBUG
        print("applicationFinishedRestoringState")
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.getFeed()
    }
    
    @objc private func pullToRefresh() {
        presenter.getFeed(forceRefresh: true)
    }
    
    func startActivitiIndicator() {
        mainQueue.async {
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }
    }
    
    func stoptActivitiIndicator() {
        mainQueue.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func insert(indexPaths: [IndexPath]) {
        mainQueue.async {
            self.tableView.performBatchUpdates({
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            })
        }
    }
    
    func reloadData() {
        mainQueue.async {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func showError(_ error: Error) {
        mainQueue.async {
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    func push(_ vc: UIViewController) {
        mainQueue.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

