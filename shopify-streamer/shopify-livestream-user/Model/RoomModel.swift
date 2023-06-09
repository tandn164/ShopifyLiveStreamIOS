//
//  RoomModel.swift
//  shopify-livestream-user
//
//  Created by Nguyễn Đức Tân on 10/08/2022.
//

import Foundation

class Room: Codable {
    let name: String?
    let rtcToken: String?
    let startTime: Int64?
    let endTime: Int64?
    let roomOwnerId: String?
    let thumb: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case rtcToken
        case startTime
        case endTime
        case roomOwnerId
        case thumb
    }
    
    var dictionary: [String: Any] {
        return ["name": name,
                "rtcToken": rtcToken,
                "startTime": startTime,
                "endTime": endTime,
                "roomOwnerId": roomOwnerId,
                "thumb": thumb]
    }
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.rtcToken = dictionary["rtcToken"] as? String
        self.startTime = dictionary["startTime"] as? Int64
        self.endTime = dictionary["endTime"] as? Int64
        self.roomOwnerId = dictionary["roomOwnerId"] as? String
        self.thumb = dictionary["thumb"] as? String
    }
    
    init(name: String?,
         rtcToken: String?,
         startTime: Int64?,
         endTime: Int64?,
         roomOwnerId: String?,
         thumb: String?
    ) {
        self.name = name
        self.rtcToken = rtcToken
        self.startTime = startTime
        self.endTime = endTime
        self.roomOwnerId = roomOwnerId
        self.thumb = thumb
    }
}

