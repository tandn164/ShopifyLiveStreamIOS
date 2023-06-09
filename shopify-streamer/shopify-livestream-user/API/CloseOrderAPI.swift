//
//  CloseOrderAPI.swift
//  shopify-livestream-user
//
//  Created by Nguyễn Đức Tân on 12/08/2022.
//

import UIKit
import Alamofire

struct CloseOrderAPI: API {
    var expandPath: String?
    
    var path: APIPath { .closeOrderStatus }
            
    var method: HTTPMethod { .post }
    
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
              completion: @escaping (Order?, Error?) -> Void) {
        sendToShopify(of: OrderModel.self, queue: queue, decoder: decoder) { result, error in
            completion(result?.order, error)
        }
    }
}

struct CancelOrderAPI: API {
    var expandPath: String?
    
    var path: APIPath { .cancelOrderStatus }
            
    var method: HTTPMethod { .post }
    
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
              completion: @escaping (Order?, Error?) -> Void) {
        sendToShopify(of: OrderModel.self, queue: queue, decoder: decoder) { result, error in
            completion(result?.order, error)
        }
    }
}
