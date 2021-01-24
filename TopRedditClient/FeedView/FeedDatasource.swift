//
//  FeedDatasource.swift
//  TopRedditClient
//
//  Created by Alix on 12/8/20.
//

import UIKit

final class FeedDatasource: NSObject, UITableViewDataSource {
    
    private var tableView: UITableView
    private var presenter: FeedPresenter
    
    init(tableView: UITableView, presenter: FeedPresenter) {
        self.presenter = presenter
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: String(describing: ListingTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ListingTableViewCell.self))
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ListingTableViewCell.self), for: indexPath) as! ListingTableViewCell
        cell.item = presenter.items[indexPath.row]
        return cell
    }
}
