//
//  GetAgoraTokenAPI.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 10/07/2022.
//

import UIKit
import Alamofire

struct GetAgoraTokenAPI: API {
    
    var path: APIPath { .agoraToken }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .get }

    init( params: Parameter? = nil) {
        parameters = params
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping (RTCTokenModel?, Error?) -> Void) {
        send(of: RTCTokenModel.self, queue: queue, decoder: decoder) { token, error in
            completion(token, error)
        }
    }
}

struct RTCTokenModel: Codable {
    let rtcToken: String?
    
    enum CodingKeys: String, CodingKey {
        case rtcToken
    }
}
