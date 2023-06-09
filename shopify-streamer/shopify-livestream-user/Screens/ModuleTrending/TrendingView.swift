//
//  TrendingView.swift
//  shopify-livestream-user
//
//  Created by Nguyễn Đức Tân on 12/08/2022.
//

import UIKit

protocol TrendingViewDelegate: AnyObject {
    func updateOrder()
}

class TrendingView: UIView, AppViewProtocol {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var orders: [Order] = []
    weak var delegate: TrendingViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(for: "TrendingView")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCellByNib(TrendingTableViewCell.self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(for: "TrendingView")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCellByNib(TrendingTableViewCell.self)
    }
    
    func setupView(orders: [Order]) {
        self.orders = orders
        tableView.reloadData()
    }
}

extension TrendingView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCell(TrendingTableViewCell.self, forIndexPath: indexPath) else {
            return UITableViewCell()
        }
        cell.updateUI(order: orders[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TrendingView: TrendingTableViewCellDelegate {
    func updateOrder() {
        delegate?.updateOrder()
    }
}
