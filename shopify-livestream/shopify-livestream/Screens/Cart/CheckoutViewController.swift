//
//  CheckoutViewController.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 11/08/2022.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class CheckoutViewController: UIViewController {

    @IBOutlet weak var totalBill: UILabel!
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var phonenumber: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var zipcode: UITextField!
    @IBOutlet weak var itemStackView: UIStackView!
    
    var product: [CartModel] = []
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checkout"
        var totalBill = 0
        product.forEach { cart in
            let view = CartView()
            view.initView(data: cart, isCheckout: true)
            itemStackView.addArrangedSubview(view)
            totalBill += cart.productPrice ?? 0
        }
        
        itemStackView.layoutSubviews()
        itemStackView.layoutIfNeeded()
        
        self.totalBill.text = "Total bill: \("\(Util.formatNumber(totalBill))đ")"
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        db.collection("users").document(currentUser.uid).getDocument { document, error in
            let user = User(dictionary: document?.data() ?? [:])
            let address = user.address
            self.firstname.text = address?.firstName
            self.lastname.text = address?.lastName
            self.address.text = address?.address1
            self.phonenumber.text = address?.phone
            self.city.text = address?.city
            self.country.text = address?.country
            self.zipcode.text = address?.zip
        }
    }
    
    @IBAction func checkoutAction(_ sender: UIButton) {
        guard let shopId = product.first?.shopId, !shopId.isEmpty, let currentUser = Auth.auth().currentUser else {
            return
        }
        if (firstname.text?.isEmpty ?? true)
            || (lastname.text?.isEmpty ?? true)
            || (address.text?.isEmpty ?? true)
            || (phonenumber.text?.isEmpty ?? true)
            || (city.text?.isEmpty ?? true)
            || (country.text?.isEmpty ?? true)
            || (zipcode.text?.isEmpty ?? true) {
            UIAlertController.show(message: "You must fill all address infomation", title: nil)

            return
        }
        db.collection("users").document(shopId).getDocument { document, error in
            let shop = User(dictionary: document?.data() ?? [:])
            DataLocal.shopifyToken = shop.shopifyToken
            var lineItems: [LineItem] = []
            self.product.forEach { cart in
                lineItems.append(LineItem(variantId: cart.variantId, quantity: cart.quantity))
            }
            let order = OrderModel(order: Order(lineItems: lineItems,
                                                email: currentUser.email ?? "",
                                                shippingAddress:
                                                    AddressModel(
                                                        firstName: self.firstname.text,
                                                        lastName: self.lastname.text,
                                                        address1: self.address.text,
                                                        phone: self.phonenumber.text,
                                                        city: self.city.text,
                                                        country: self.country.text,
                                                        zip: self.zipcode.text)))
            do {
                let encodedData = try JSONEncoder().encode(order)
                let jsonString = String(data: encodedData,
                                        encoding: .utf8)
                var param = Parameter()
                param.addParam("order", value: jsonString)
                CreateOrderAPI().send(jsonData: jsonString ?? "") { result, error in
                    if let error = error {
                        UIAlertController.show(message: error.localizedDescription, title: nil)
                        return
                    }
                    guard let _ = result else {
                        return
                    }
                    self.db.collection("users").document(currentUser.uid).updateData(["cart" : []])
                    UIAlertController.show(message: "Order Success!!!", title: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } catch {
            }
        }
    }
}
