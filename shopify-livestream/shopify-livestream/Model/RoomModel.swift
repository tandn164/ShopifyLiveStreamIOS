//
//  RoomModel.swift
//  shopify-livestream
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
    var actorName: String?
    var liveProduct: [LiveProduct]?
    var viewer: [Viewer]?
    var favorite: [Favorite]?
    
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
                "thumb": thumb,
                "liveProduct": (liveProduct ?? []).map({ product in
            return product.dictionary
        }),
                "viewer": (viewer ?? []).map({ view in
            return view.dictionary
        }),
                "favorite": (favorite ?? []).map({ view in
            return view.dictionary
        }),
        ]
    }
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.rtcToken = dictionary["rtcToken"] as? String
        self.startTime = dictionary["startTime"] as? Int64
        self.endTime = dictionary["endTime"] as? Int64
        self.roomOwnerId = dictionary["roomOwnerId"] as? String
        self.thumb = dictionary["thumb"] as? String
        if let dics = dictionary["liveProduct"] as? [[String: Any]] {
            var liveProduct: [LiveProduct] = []
            for dic in dics {
                liveProduct.append(LiveProduct(dictionary: dic))
            }
            self.liveProduct = liveProduct
        }
        if let views = dictionary["viewer"] as? [[String: Any]] {
            var viewer: [Viewer] = []
            for dic in views {
                viewer.append(Viewer(dictionary: dic))
            }
            self.viewer = viewer
        }
        if let favorites = dictionary["favorite"] as? [[String: Any]] {
            var fav: [Favorite] = []
            for dic in favorites {
                fav.append(Favorite(dictionary: dic))
            }
            self.favorite = fav
        }
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
