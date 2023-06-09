//
//  UpdateCartAPI.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 21/07/2022.
//

import UIKit
import Alamofire

struct UpdateCartAPI: API {
    
    var path: APIPath { .cart }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .put }
    
    var headers: HTTPHeaders?
    
    init( params: Parameter? = nil) {
        parameters = params
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping (UpdateCartResultModel?, Error?) -> Void) {
        send(of: UpdateCartResultModel.self) { result, error in
            completion(result, error)
        }
    }
}

struct UpdateCartResultModel: Decodable {
    let message: String?
    let result: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case result
    }
}
