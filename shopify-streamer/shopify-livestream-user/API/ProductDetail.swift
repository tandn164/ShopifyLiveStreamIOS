//
//  ProductDetail.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 17/07/2022.
//

import UIKit
import Alamofire

struct ProductDetailAPI: API {
    var expandPath: String?
    
    var path: APIPath { .getProductDetail }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .get }

    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers.addAccessToken()
        headers.addContentType()
        return headers
    }
    
    init(expand: String) {
        expandPath = expand
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping (ProductDetail?, Error?) -> Void) {
        sendToShopify(of: ProductDetail.self, queue: queue, decoder: decoder) { product, error in
            completion(product, error)
        }
    }
}

struct ProductDetail: Decodable {
    let product: Product?
    
    enum CodingKeys: String, CodingKey {
        case product
    }
}


struct Product: Decodable {
    let id: Int?
    let title: String?
    let body_html: String?
    let product_type: String?
    let image: ProductImage?
    let variants: [ProductVariant]?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body_html
        case product_type
        case image
        case variants
        case category
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
