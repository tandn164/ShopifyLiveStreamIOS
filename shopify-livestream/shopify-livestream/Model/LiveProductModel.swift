//
//  ListProductModel.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 11/08/2022.
//

struct LiveProduct: Decodable {
    let shopId: String?
    let variantId: Int?
    let shopName: String?
    let productId: Int?
    let productThumbnail: String?
    let productTitle: String?
    let productCategory: String?
    let productPrice: Int?
    let productOriginPrice: Int?

    var dictionary: [String: Any] {
        return ["shopId": shopId,
                "variantId": variantId,
                "shopName": shopName,
                "productId": productId,
                "productThumbnail": productThumbnail,
                "productTitle": productTitle,
                "productCategory": productCategory,
                "productPrice": productPrice,
                "productOriginPrice": productOriginPrice
        ]
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
    }
    
    
    enum CodingKeys: String, CodingKey {
        case shopId
        case variantId
        case shopName
        case productId = "product_Id"
        case productThumbnail = "product_thumb"
        case productTitle = "product_title"
        case productCategory = "product_category"
        case productPrice = "product_price"
        case productOriginPrice = "product_originPrice"
    }
}
