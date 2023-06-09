//
//  GetListOrderAPI.swift
//  shopify-livestream-user
//
//  Created by Nguyễn Đức Tân on 12/08/2022.
//

import UIKit
import Alamofire

struct GetListOpenOrderAPI: API {
    var expandPath: String?
    
    var path: APIPath { .openOrder }
            
    var method: HTTPMethod { .get }
    
    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers.addAccessToken()
        headers.addContentType()
        return headers
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping ([Order]?, Error?) -> Void) {
        sendToShopify(of: OrderModel.self, queue: queue, decoder: decoder) { result, error in
            completion(result?.orders, error)
        }
    }
}

struct GetListClosedOrderAPI: API {
    var expandPath: String?
    
    var path: APIPath { .closeOrder }
            
    var method: HTTPMethod { .get }
    
    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers.addAccessToken()
        headers.addContentType()
        return headers
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping ([Order]?, Error?) -> Void) {
        sendToShopify(of: OrderModel.self, queue: queue, decoder: decoder) { result, error in
            completion(result?.orders, error)
        }
    }
}

struct GetListCancelOrderAPI: API {
    var expandPath: String?
    
    var path: APIPath { .cancelOrder }
            
    var method: HTTPMethod { .get }
    
    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers.addAccessToken()
        headers.addContentType()
        return headers
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping ([Order]?, Error?) -> Void) {
        sendToShopify(of: OrderModel.self, queue: queue, decoder: decoder) { result, error in
            completion(result?.orders, error)
        }
    }
}
