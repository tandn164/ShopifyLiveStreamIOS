//
//  OrderModel.swift
//  shopify-livestream-user
//
//  Created by Nguyễn Đức Tân on 12/08/2022.
//

import Foundation

struct OrderModel: Codable {
    let orders: [Order]?
    let order: Order?
    enum CodingKeys: String, CodingKey {
        case orders
        case order
    }
}

struct Order: Codable {
    let id: Int
    let lineItems: [LineItem]?
    let email: String?
    let shippingAddress: AddressModel?
    let totalPrice: String?
    let cancelledAt: String?
    let closedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case lineItems = "line_items"
        case email
        case shippingAddress = "shipping_address"
        case totalPrice = "total_line_items_price"
        case cancelledAt = "cancelled_at"
        case closedAt = "closed_at"
    }
}

struct LineItem: Codable {
    let name: String?
    let price: String?
    let quantity: Int?
    let productId: Int?
    
    enum CodingKeys: String, CodingKey {
        case quantity
        case price
        case name
        case productId = "product_id"
    }
}

class AddressModel: Codable {
    let firstName: String?
    let lastName: String?
    let address1: String?
    let phone: String?
    let city: String?
    let country: String?
    let zip: String?

    var dictionary: [String: Any] {
        return ["first_name": firstName,
                "last_name": lastName,
                "address1": address1,
                "phone": phone,
                "city": city,
                "country": country,
                "zip": zip
        ]
    }
    
    init(firstName: String?,
         lastName: String?,
         address1: String?,
         phone: String?,
         city: String?,
         country: String?,
         zip: String?
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.address1 = address1
        self.phone = phone
        self.city = city
        self.country = country
        self.zip = zip
    }
    
    init(dictionary: [String: Any]) {
        self.firstName = dictionary["first_name"] as? String
        self.lastName = dictionary["last_name"] as? String
        self.address1 = dictionary["address1"] as? String
        self.phone = dictionary["phone"] as? String
        self.city = dictionary["city"] as? String
        self.country = dictionary["country"] as? String
        self.zip = dictionary["zip"] as? String
    }
    
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case address1
        case phone
        case city
        case country
        case zip
    }
}

