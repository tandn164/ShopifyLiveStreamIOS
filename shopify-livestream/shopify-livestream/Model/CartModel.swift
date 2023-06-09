//
//  CardModel.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 11/08/2022.
//

import Foundation

class CartModel: Codable {
    let shopId: String?
    let variantId: Int?
    let shopName: String?
    let productId: Int?
    let productThumbnail: String?
    let productTitle: String?
    let productCategory: String?
    let productPrice: Int?
    let productOriginPrice: Int?
    let userId: String?
    var quantity: Int?
    var isSelected: Bool?

    var dictionary: [String: Any] {
        return ["shopId": shopId,
                "variantId": variantId,
                "shopName": shopName,
                "productId": productId,
                "productThumbnail": productThumbnail,
                "productTitle": productTitle,
                "productCategory": productCategory,
                "productPrice": productPrice,
                "productOriginPrice": productOriginPrice,
                "userId": userId,
                "quantity": quantity
        ]
    }
    
    init(shopId: String?,
         variantId: Int?,
         shopName: String?,
         productId: Int?,
         productThumbnail: String?,
         productTitle: String?,
         productCategory: String?,
         productPrice: Int?,
         productOriginPrice: Int?,
         userId: String?,
         quantity: Int?
    ) {
        self.shopName = shopName
        self.variantId = variantId
        self.shopId = shopId
        self.productId = productId
        self.productThumbnail = productThumbnail
        self.productTitle = productTitle
        self.productCategory = productCategory
        self.productPrice = productPrice
        self.productOriginPrice = productOriginPrice
        self.userId = userId
        self.quantity = quantity
    }
    
    init(dictionary: [String: Any]) {
        self.shopId = dictionary["shopId"] as? String
        self.variantId = dictionary["variantId"] as? Int
        self.shopName = dictionary["shopName"] as? String
        self.productId = dictionary["productId"] as? Int
        self.productThumbnail = dictionary["productThumbnail"] as? String
        self.productTitle = dictionary["productTitle"] as? String
        self.productCategory = dictionary["productCategory"] as? String
        self.productPrice = dictionary["productPrice"] as? Int
        self.productOriginPrice = dictionary["productOriginPrice"] as? Int
        self.quantity = dictionary["quantity"] as? Int
        self.userId = dictionary["userId"] as? String
    }
    
    
    enum CodingKeys: String, CodingKey {
        case shopId
        case variantId
        case shopName
        case productId
        case productThumbnail
        case productTitle
        case productCategory
        case productPrice
        case productOriginPrice
        case quantity
        case userId
    }
}

