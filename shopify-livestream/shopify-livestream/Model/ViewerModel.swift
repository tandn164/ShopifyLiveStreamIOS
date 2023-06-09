//
//  ViewerModel.swift
//  shopify-livestream
//
//  Created by Nguyễn Đức Tân on 10/08/2022.
//

import Foundation

import Foundation

class Viewer: Codable {
    let id: String?
    let room: String?
    let username: String?
    let thumbnail: String?
    let userId: String?
    let agoraId: Int?
    var isInvited: Bool?
    
    var dictionary: [String: Any] {
        return ["id": id,
                "room": room,
                "username": username,
                "thumbnail": thumbnail,
                "agoraId": agoraId,
                "userId": userId]
    }
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.room = dictionary["room"] as? String
        self.username = dictionary["username"] as? String
        self.thumbnail = dictionary["thumbnail"] as? String
        self.userId = dictionary["userId"] as? String
        self.agoraId = dictionary["agoraId"] as? Int
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case room
        case username
        case thumbnail
        case userId
        case agoraId
    }
}
