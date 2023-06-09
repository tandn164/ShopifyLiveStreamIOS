//
//  ListCategory.swift
//  YoutubeClone
//
//  Created by Nguyễn Đức Tân on 17/07/2022.
//

import UIKit
import Alamofire

struct ListCategoryAPI: API {
    var expandPath: String?
    
    var path: APIPath { .listCategory }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .get }
    
    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers.addAccessToken()
        headers.addContentType()
        return headers
    }

    init( params: Parameter? = nil) {
        parameters = params
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping (ListCategory?, Error?) -> Void) {
        sendToShopify(of: ListCategory.self, queue: queue, decoder: decoder) { listProduct, error in
            completion(listProduct, error)
        }
    }
}

struct ListCategory: Decodable {
    let categories: [Category]
    
    enum CodingKeys: String, CodingKey {
        case categories = "custom_collections"
    }
}

struct Category: Decodable {
    let id: Int?
    let title: String?
    let body_html: String?
    let image: ProductImage?
    let products: [Product]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body_html
        case image
        case products
    }
}
