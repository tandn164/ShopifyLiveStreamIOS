//
//  CartViewController.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 18/04/2022.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class CartViewController: BaseViewController {

    @IBOutlet weak var stackView: UIStackView!
    
    var listCart: [[CartModel]] = []
    var flatList: [CartModel] = []
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    func getData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        listCart.removeAll()
        stackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                UIAlertController.show(message: error.localizedDescription, title: nil)
                return
            }
            let user = User(dictionary: document?.data() ?? [:])
            let carts = user.cart
            var uniqueCarts: [CartModel] = []
            carts?.forEach { cart in
                if !uniqueCarts.contains(where: { uniqueCart in
                    uniqueCart.productId == cart.productId
                }) {
                    uniqueCarts.append(cart)
                } else {
                    let index = uniqueCarts.firstIndex { uniqueCart in
                        return cart.productId == uniqueCart.productId
                    } ?? 0
                    uniqueCarts[index].quantity = (uniqueCarts[index].quantity ?? 0) + (cart.quantity ?? 0)
                }
            }
            self.flatList = uniqueCarts
            
            var uniqueShop: [String] = []
            uniqueCarts.forEach { cart in
                if !uniqueShop.contains(where: { shopId in
                    shopId == cart.shopId
                }) {
                    uniqueShop.append(cart.shopId ?? "")
                }
            }
            
            uniqueShop.forEach { shopId in
                self.listCart.append(uniqueCarts.filter({ cart in
                    cart.shopId == shopId
                }))
            }
            
            for index in 0..<self.listCart.count {
                let view = CartByShopView()
                view.initView(shopName: self.listCart[index].first?.shopName ?? "", index: index, listProduct: self.listCart[index])
                view.delegate = self
                self.stackView.addArrangedSubview(view)
            }
            
            self.stackView.layoutSubviews()
        }
    }
    
    @IBAction func checkoutAction(_ sender: UIButton) {
        if flatList.isEmpty {
            UIAlertController.show(message: "There's no item to checkout", title: nil)
            return
        }
        let vc = CheckoutViewController()
        vc.product = flatList
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CartViewController: CartByShopViewDelegate {
    func removeFrame(index: Int) {
        self.stackView.subviews[index].removeFromSuperview()
    }
    
    func didSelect(product: CartModel) {
    }
    
    func didDesekect(product: CartModel) {
    }
    
    func updateItem(product: CartModel) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        if let index = flatList.firstIndex(where: { cart in
            return cart.productId == product.productId
        }) {
            flatList[index] = product
            if product.quantity == 0 {
                flatList.remove(at: index)
            }
            db.collection("users").document(uid).updateData(["cart": flatList.map({ cart in
                return cart.dictionary
            })])
        }
    }
}
