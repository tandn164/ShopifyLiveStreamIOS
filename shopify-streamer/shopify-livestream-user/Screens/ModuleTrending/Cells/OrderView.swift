//
//  OrderView.swift
//  shopify-livestream-user
//
//  Created by Nguyễn Đức Tân on 12/08/2022.
//

import UIKit
import Kingfisher

class OrderView: UIView, AppViewProtocol {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(for: "OrderView")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(for: "OrderView")
    }
    
    func setupView(item: LineItem) {
        price.text = item.price
        quantity.text = "Quantity: \(item.quantity ?? 0)"
        name.text = item.name
        ProductDetailAPI(expand: "/products/\(item.productId ?? 0)").send { productDetail, error in
            let url = URL(string: productDetail?.product?.image?.src ?? "")
            self.thumbnail.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        }
    }
}
