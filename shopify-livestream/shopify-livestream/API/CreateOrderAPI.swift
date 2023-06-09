//
//  CreateOrderAPI.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 11/08/2022.
//

import UIKit
import Alamofire

struct CreateOrderAPI: API {
    
    var path: APIPath { .createOrder }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .post }
    
    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers.addContentType()
        headers.addAccessToken()
        return headers
    }
    
    init( params: Parameter? = nil) {
        parameters = params
    }
    
    func send(jsonData: String, completion: @escaping (OrderModel?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://tannd176865.myshopify.com/admin/orders.json")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(DataLocal.shopifyToken ?? "", forHTTPHeaderField: "X-Shopify-Access-Token")
        request.httpBody = (jsonData).data(using: .utf8)
        print(jsonData)
        AF.request(request).responseDecodable(of: OrderModel.self) { response in
            switch response.result {
            case let .success(data):
                completion(data, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }
}

struct OrderModel: Codable {
    let order: Order?
    
    enum CodingKeys: String, CodingKey {
        case order
    }
}

struct Order: Codable {
    let lineItems: [LineItem]
    let email: String
    let shippingAddress: AddressModel
    
    enum CodingKeys: String, CodingKey {
        case lineItems = "line_items"
        case email
        case shippingAddress = "shipping_address"
    }
}

struct LineItem: Codable {
    let variantId: Int?
    let quantity: Int?

    enum CodingKeys: String, CodingKey {
        case variantId = "variant_id"
        case quantity
    }
}
