//
//  CartByShopView.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 11/08/2022.
//

import UIKit

protocol CartByShopViewDelegate: AnyObject {
    func didSelect(product: CartModel)
    func didDesekect(product: CartModel)
    func updateItem(product: CartModel)
    func removeFrame(index: Int)
}

class CartByShopView: UIView, CustomViewProtocol {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    weak var delegate: CartByShopViewDelegate?
    var listProduct: [CartModel] = []
    var index: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(for: "CartByShopView")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(for: "CartByShopView")
    }
    
    func initView(shopName: String, index: Int, listProduct: [CartModel]) {
        self.index = index
        self.listProduct = listProduct
        self.shopName.text = shopName
        stackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        listProduct.forEach { product in
            let view = CartView()
            view.delegate = self
            view.initView(data: product)
            stackView.addArrangedSubview(view)
        }
    }

}

extension CartByShopView: CartViewDelegate {
    func didSelect(product: CartModel) {
    }
    
    func didDesekect(product: CartModel) {
    }
    
    func updateItem(product: CartModel) {
        if product.quantity == 0 {
            if let index = listProduct.firstIndex(where: { cart in
                cart.productId == product.productId
            }) {
                listProduct.remove(at: index)
            }
            if listProduct.isEmpty {
                delegate?.removeFrame(index: index)
            } else {
                stackView.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                listProduct.forEach { product in
                    let view = CartView()
                    view.delegate = self
                    view.initView(data: product)
                    stackView.addArrangedSubview(view)
                }
            }
        }
        delegate?.updateItem(product: product)
    }
    
}
