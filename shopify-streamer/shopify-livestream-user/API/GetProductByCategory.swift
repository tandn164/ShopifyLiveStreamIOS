//
//  GetProductByCategory.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 17/07/2022.
//

import UIKit
import Alamofire

struct GetProductByCategoryAPI: API {
    var expandPath: String?
    
    var path: APIPath { .getProductByCategory }
            
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
              completion: @escaping (ListProduct?, Error?) -> Void) {
        sendToShopify(of: ListProduct.self, queue: queue, decoder: decoder) { listProduct, error in
            completion(listProduct, error)
        }
    }
}

struct ListProduct: Decodable {
    let products: [Product]
    
    enum CodingKeys: String, CodingKey {
        case products
    }
}
