//
//  ListLiveAPI.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 09/05/2022.
//

import UIKit
import Alamofire

struct ListLiveAPI: API {
    
    var path: APIPath { .liveInfo }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .get }
    
    var headers: HTTPHeaders?
    
    init( params: Parameter? = nil) {
        parameters = params
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping (ListLive?, Error?) -> Void) {
        sendMock(of: ListLiveModel.self) { result, error in
            completion(result?.data, error)
        }
    }
}

struct ListLiveModel: Decodable {
    let data: ListLive?
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct ListLive: Decodable {
    let lives: [Live]
    
    enum CodingKeys: String, CodingKey {
        case lives
    }
}

struct Live: Decodable {
    let id: Int?
    let name: String?
    let shopId: Int?
    let numberOfViews: Int?
    let thumbnail: String?
    let shopName: String?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shopId
        case numberOfViews
        case thumbnail
        case shopName
        case status
    }
}
