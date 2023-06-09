//
//  UserModel.swift
//  shopify-livestream-user
//
//  Created by Nguyễn Đức Tân on 10/08/2022.
//

import Foundation

class User: NSObject, NSCoding, Codable {
    let email: String?
    let password: String?
    let storeName: String?
    let shopifyToken: String?
    let role: String?
    let thumb: String?
    let balace: Float?
    let coinBalance: Float?
    let agoraUID: UInt?
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case storeName
        case shopifyToken
        case role
        case thumb
        case balace
        case coinBalance
        case agoraUID
    }
    
    var dictionary: [String: Any] {
        return ["email": email,
                "password": password,
                "storeName": storeName,
                "shopifyToken": shopifyToken,
                "role": role,
                "thumb": thumb,
                "balace": balace,
                "coinBalance": coinBalance,
                "agoraUID": agoraUID
        ]
    }
    
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String
        self.password = dictionary["password"] as? String
        self.storeName = dictionary["storeName"] as? String
        self.shopifyToken = dictionary["shopifyToken"] as? String
        self.role = dictionary["role"] as? String
        self.thumb = dictionary["thumb"] as? String
        self.balace = dictionary["balace"] as? Float
        self.coinBalance = dictionary["coinBalance"] as? Float
        print(555555, dictionary["agoraUID"])
        self.agoraUID = dictionary["agoraUID"] as? UInt
        print(56666, dictionary["agoraUID"] as? UInt)
    }
    
    init(email: String?,
         password: String?,
         storeName: String?,
         shopifyToken: String?,
         role: String?,
         thumb: String?,
         balace: Float?,
         coinBalance: Float?,
         agoraUID: UInt?
    ) {
        self.email = email
        self.password = password
        self.storeName = storeName
        self.shopifyToken = shopifyToken
        self.role = role
        self.thumb = thumb
        self.balace = balace
        self.coinBalance = coinBalance
        self.agoraUID = agoraUID
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let email = aDecoder.decodeObject(forKey: "email") as? String
        let password = aDecoder.decodeObject(forKey: "password") as? String
        let storeName = aDecoder.decodeObject(forKey: "storeName") as? String
        let shopifyToken = aDecoder.decodeObject(forKey: "shopifyToken") as? String
        let role = aDecoder.decodeObject(forKey: "role") as? String
        let thumb = aDecoder.decodeObject(forKey: "thumb") as? String
        let coinBalance = aDecoder.decodeObject(forKey: "coinBalance") as? Float
        let balace = aDecoder.decodeObject(forKey: "balace") as? Float
        let agoraUID = aDecoder.decodeObject(forKey: "agoraUID") as? UInt

        self.init(
            email: email,
            password: password,
            storeName: storeName,
            shopifyToken: shopifyToken,
            role: role,
            thumb: thumb,
            balace: balace,
            coinBalance: coinBalance,
            agoraUID: agoraUID
        )
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: "email")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(storeName, forKey: "storeName")
        aCoder.encode(shopifyToken, forKey: "shopifyToken")
        aCoder.encode(role, forKey: "role")
        aCoder.encode(thumb, forKey: "thumb")
        aCoder.encode(coinBalance, forKey: "coinBalance")
        aCoder.encode(balace, forKey: "balace")
        aCoder.encode(agoraUID, forKey: "agoraUID")

    }
}

