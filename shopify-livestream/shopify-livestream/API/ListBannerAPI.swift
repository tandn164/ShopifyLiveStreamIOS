//
//  ListBannerAPI.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 09/05/2022.
//

import UIKit
import Alamofire

struct ListBannerAPI: API {
    
    var path: APIPath { .listBanner }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .get }
    
    var headers: HTTPHeaders?
    
    init( params: Parameter? = nil) {
        parameters = params
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping (ListBanner?, Error?) -> Void) {
        sendMock(of: ListBannerModel.self) { result, error in
            completion(result?.data, error)
        }
    }
}

struct ListBannerModel: Decodable {
    let data: ListBanner?
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct ListBanner: Decodable {
    let banners: [Banner]
    
    enum CodingKeys: String, CodingKey {
        case banners
    }
}

struct Banner: Decodable {
    let id: Int?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl
    }
}
