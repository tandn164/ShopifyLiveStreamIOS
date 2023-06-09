//
//  AddCartAPI.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 21/07/2022.
//

import UIKit
import Alamofire

struct AddCartAPI: API {
    
    var path: APIPath { .cart }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .post }
    
    var headers: HTTPHeaders?
    
    init( params: Parameter? = nil) {
        parameters = params
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping (AddCartResultModel?, Error?) -> Void) {
        send(of: AddCartResultModel.self) { result, error in
            print(result)
            completion(result, error)
        }
    }
}

struct AddCartResultModel: Decodable {
    let message: String?
    let result: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case result
    }
}
