//
//  API.swift
//  CoreApp
//
//  Created by Nguyễn Đức Tân on 28/04/2022.
//

import UIKit
import Alamofire

public typealias Parameter = Parameters
public typealias DataUpLoad = (data: Data, name: String, fileName: String, mimeType: String)

struct HeaderKey {
    static let Accept              = "Accept"
    static let ContentType         = "Content-Type"
    static let Authorization       = "Authorization"
    static let AccessToken         = "X-Shopify-Access-Token"
}

struct HeaderValue {
    static let applicationJson = "application/json"
}

enum APIPath: String {
    case undefined = ""
    case liveInfo = "/live-info-list"
    case listBanner = "/banner-list"
    case listProduct = "/shopify/app/products"
    
    case rtcToken = "/rtc"
    case getProductDetail = ".json"
    
    case getProductByCategory = "/products.json"
    case openOrder = "/orders.json?status=open"
    case closeOrder = "/orders.json?status=closed"
    case cancelOrder = "/orders.json?status=cancelled"
    case listCategory = "/custom_collections.json"
    case closeOrderStatus = "/close.json"
    case cancelOrderStatus = "/cancel.json"
}

protocol API {
    var path: APIPath { get }
    var parameters: Parameters? { get }
    var expandPath: String? { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
}

extension API {
    var path: APIPath { .undefined }
    var parameters: Parameters? { nil }
    var expandPath: String? { nil }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { nil }
}

extension API {
    func send<T: Decodable>(of type: T.Type = T.self,
                            queue: DispatchQueue = .main,
                            decoder: DataDecoder = JSONDecoder(),
                            completion: @escaping (T?, Error?) -> Void) {

        let url = "https://589e-42-112-171-236.ap.ngrok.io\(path.rawValue)\(expandPath ?? "")"
        let request = AF.request(url,
                                 method: method,
                                 parameters: parameters,
                                 headers: headers)
        request.responseDecodable(of: T.self) { (response) in
            
            switch response.result {
            case let .success(data):
                completion(data, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }
    
    func sendToShopify<T: Decodable>(of type: T.Type = T.self,
                            queue: DispatchQueue = .main,
                            decoder: DataDecoder = JSONDecoder(),
                            completion: @escaping (T?, Error?) -> Void) {

        let url = "https://tannd176865.myshopify.com/admin\(expandPath ?? "")\(path.rawValue)"
        print(9787878, url)
        let request = AF.request(url,
                                 method: method,
                                 parameters: parameters,
                                 headers: headers)
        request.responseDecodable(of: T.self) { (response) in
            
            switch response.result {
            case let .success(data):
                completion(data, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }
}

extension Parameter {
    mutating func addParam(_ key: String, value: Value?) {
        if let valueObj = value {
            updateValue(valueObj, forKey: key)
        }
    }
}

extension HTTPHeaders {
    
    mutating func addAccept() {
        add(name: HeaderKey.Accept, value: HeaderValue.applicationJson)
    }
    
    mutating func addAuthorization() {
        let value = "Bearer "
        add(name: HeaderKey.Authorization, value: value)
    }
    
    mutating func addContentType() {
        add(name: HeaderKey.ContentType, value: HeaderValue.applicationJson)
    }
    
    mutating func addAccessToken() {
        add(name: HeaderKey.AccessToken, value: DataLocal.getObject(AppKey.shopifyToken) as? String ?? "")
    }
}


class DataLocal: NSObject {
    class func saveObject(_ value: Any?, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
    }
        
    class func getObject(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    class func removeObject(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    class func saveData(forKey key: String, _ object: Any?) {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        DataLocal.saveObject(data, forKey: key)
    }
    
    class func getData(forKey key: String) -> Any? {
        guard let data = DataLocal.getObject(key) as? Data else {
            return nil
        }
        guard let unarchiveData = NSKeyedUnarchiver.unarchiveObject(with: data) else {
                return nil
        }
        return unarchiveData
    }
    
    static var shopifyToken: String? {
        get {
            return UserDefaults.standard.shopifyToken
        }
        set(newValue) {
            UserDefaults.standard.shopifyToken = newValue
        }
    }
}


extension UserDefaults {
    @objc dynamic var shopifyToken: String? {
        get { self.string(forKey: AppKey.shopifyToken) }
        set { self.setValue(newValue, forKey: AppKey.shopifyToken) }
    }
}
