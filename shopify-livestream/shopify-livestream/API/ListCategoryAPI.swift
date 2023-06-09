//
//  ListCategoryAPI.swift
//  CoreApp
//
//  Created by Nguyễn Đức Tân on 28/04/2022.
//

import UIKit
import Alamofire

struct ListCategoryAPI: API {
    
    var path: APIPath { .listCategory }
        
    var parameters: Parameters?
    
    var method: HTTPMethod { .get }
    
    var headers: HTTPHeaders?
    
    init( params: Parameter? = nil) {
        parameters = params
    }
    
    func send(queue: DispatchQueue = .main,
              decoder: DataDecoder = JSONDecoder(),
              completion: @escaping (ListCategory?, Error?) -> Void) {
        sendMock(of: ListCategoryModel.self) { result, error in
            completion(result?.data, error)
        }
    }
}

struct ListCategoryModel: Decodable {
    let data: ListCategory?
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct ListCategory: Decodable {
    let categories: [Category]
    
    enum CodingKeys: String, CodingKey {
        case categories = "collections"
    }
}

struct Category: Decodable {
    let id: Int?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
