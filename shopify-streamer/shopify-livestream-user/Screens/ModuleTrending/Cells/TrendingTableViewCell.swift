//
//  TrendingTableViewCell.swift
//  YoutubeClone
//
//  Created by Đức Tân Nguyễn on 08/06/2021.
//

import UIKit

class SelfSizedTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
      return self.contentSize
    }

    override var contentSize: CGSize {
      didSet {
          self.invalidateIntrinsicContentSize()
      }
    }
}

protocol TrendingTableViewCellDelegate: AnyObject {
    func updateOrder()
}

class TrendingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var actionStackView: UIStackView!
    @IBOutlet weak var stackVoew: UIStackView!
    @IBOutlet weak var totalBill: UILabel!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var paymentMethod: UILabel!
    @IBOutlet weak var status: UILabel!
    
    var order: Order?
    weak var delegate: TrendingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(order: Order) {
        self.order = order
        
        totalBill.text = "Total bill: \(Util.formatNumber(Int(order.totalPrice ?? "") ?? 0))"
        userAddress.text = "\(order.shippingAddress?.firstName ?? "") \(order.shippingAddress?.lastName ?? "")\n\(order.shippingAddress?.phone ?? "")\n\(order.shippingAddress?.city ?? ""), \(order.shippingAddress?.country ?? "")"
        paymentMethod.text = "Payment method: Cash on delivery"
        
        stackVoew.subviews.forEach { view in
            view.removeFromSuperview()
        }
        order.lineItems?.forEach({ item in
            let view = OrderView()
            view.setupView(item: item)
            stackVoew.addArrangedSubview(view)
        })
        
        if let _ = order.cancelledAt {
            status.text = "Status: Cancelled"
            actionStackView.isHidden = true
        } else if let _ = order.closedAt {
            status.text = "Status: Closed"
            actionStackView.isHidden = true
        } else {
            status.text = "Status: Open"
            actionStackView.isHidden = false
        }
        stackVoew.layoutSubviews()
        stackVoew.layoutIfNeeded()
    }
    
    @IBAction func processedAction(_ sender: UIButton) {
        guard let order = order else {
            return
        }

        CloseOrderAPI(expand: "/orders/\(order.id)").send { result, error in
            if let error = error {
                UIAlertController.show(message: error.localizedDescription, title: nil)
                return
            } else {
                self.delegate?.updateOrder()
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        guard let order = order else {
            return
        }

        CancelOrderAPI(expand: "/orders/\(order.id)").send { result, error in
            if let error = error {
                UIAlertController.show(message: error.localizedDescription, title: nil)
                return
            } else {
                self.delegate?.updateOrder()
            }
        }
    }
}
