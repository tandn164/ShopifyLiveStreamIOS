//
//  FavoriteModel.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 11/08/2022.
//

import Foundation

class Favorite: Codable {
    let username: String?
    let userId: String?
    
    var dictionary: [String: Any] {
        return ["username": username,
                "userId": userId]
    }
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String
        self.userId = dictionary["userId"] as? String
    }
    
    enum CodingKeys: String, CodingKey {
        case username
        case userId
    }
}
