//
//  ListProduct.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 27/06/2022.
//

import UIKit
import Alamofire

struct ListProductAPI: API {
    
    var path: APIPath { .listProduct }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .get }

    init( params: Parameter? = nil) {
        parameters = params
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping (ListProduct?, Error?) -> Void) {
        send(of: ListProduct.self, queue: queue, decoder: decoder) { listProduct, error in
            
        }
    }
}

struct ListProduct: Decodable {
    let products: [Product]
    
    enum CodingKeys: String, CodingKey {
        case products
    }
}

struct Product: Codable {
    let id: UInt64?
    let image: ProductImage?
    let title: String?
    let category: String?
    let variants: [ProductVariant]
    let body_html: String?
    let product_type: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case image
        case title
        case category
        case variants
        case body_html
        case product_type
    }
}

struct ProductImage: Codable {
    let src: String?
    
    enum CodingKeys: String, CodingKey {
        case src
    }
}

struct ProductVariant: Codable {
    let id: Int?
    let price: String?
    let compare_at_price: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case price
        case compare_at_price
    }
}
