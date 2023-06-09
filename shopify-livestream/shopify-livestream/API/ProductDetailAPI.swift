//
//  ProductDetailAPI.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 08/08/2022.
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
        headers.addContentType()
        headers.addAccessToken()
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
