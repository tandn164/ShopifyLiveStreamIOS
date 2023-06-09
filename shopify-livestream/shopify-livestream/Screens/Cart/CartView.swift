//
//  CartView.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 11/08/2022.
//

import UIKit

protocol CartViewDelegate: AnyObject {
    func didSelect(product: CartModel)
    func didDesekect(product: CartModel)
    func updateItem(product: CartModel)
}

class CartView: UIView, CustomViewProtocol {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var imageProduct: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelBrandName: UILabel!
    @IBOutlet var labelPrice: UILabel!
    @IBOutlet var labelOriginalPrice: UILabel!
    @IBOutlet var labelItems: UILabel!
    @IBOutlet var buttonAddItem: UIButton!
    @IBOutlet var buttonRemoveItem: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var quantityLabel: UILabel!
    
    weak var delegate: CartViewDelegate?
    var product: CartModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(for: "CartView")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(for: "CartView")
    }
    
    func initView(data: CartModel, isCheckout: Bool = false) {
        buttonStackView.isHidden = isCheckout
        quantityLabel.isHidden = !isCheckout
        quantityLabel.text = "Quantity: \(data.quantity ?? 0)"
        self.product = data
        let url = URL(string: data.productThumbnail ?? "")
        imageProduct.kf.setImage(with: url)
        labelTitle.text = data.productTitle
        labelBrandName.text = data.productCategory
        labelItems.text = "\(data.quantity ?? 0)"
        labelPrice.text = "\(Util.formatNumber(data.productPrice ?? 0))đ"
        labelOriginalPrice.text = "\(Util.formatNumber(data.productOriginPrice ?? 0))đ"
        labelOriginalPrice.isHidden = data.productOriginPrice == nil
    }
    
    @IBAction func plusButton(_ sender: UIButton) {
        product?.quantity = (product?.quantity ?? 0) + 1
        labelItems.text = "\(product?.quantity ?? 0)"
        delegate?.updateItem(product: product!)
    }
    
    @IBAction func minusButton(_ sender: UIButton) {
        if product?.quantity ?? 0 > 0 {
            product?.quantity = (product?.quantity ?? 0) - 1
            labelItems.text = "\(product?.quantity ?? 0)"
        }
        delegate?.updateItem(product: product!)
    }
}
