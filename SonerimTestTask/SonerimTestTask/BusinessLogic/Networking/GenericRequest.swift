//
//  GenericRequest.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 25.02.2025.
//

import Foundation

protocol Request {
    var method:String {get}
    var path:String {get}
    var parameters:[String:String] {get}
    var headers:[String:String] {get}
    var body:Data? {get}
    associatedtype SuccessType:Decodable
}

extension Request {
    func asURLRequest() throws -> URLRequest {
        
        guard let url = URL(string: path) else {
            throw URLError(.badURL)
        }
        
        let resultURL:URL
        
        if parameters.isEmpty {
            resultURL = url
        }
        else {
            let quesyItems:[URLQueryItem] =
            parameters
                .filter({!$0.key.isEmpty && !$0.value.isEmpty})
                .compactMap({ key, value in
                    return URLQueryItem(name: key, value: value)
                })
            
            resultURL = url.appending(queryItems:quesyItems)
        }
        
        var urlRequest = URLRequest(url: resultURL)
        
        urlRequest.httpMethod = method
        
        if !headers.isEmpty {
            headers
                .filter({!$0.key.isEmpty && !$0.value.isEmpty})
                .forEach({
                urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
            })
        }
        
        guard let data = body, !data.isEmpty else {
            return urlRequest
        }
        
        urlRequest.httpBody = data
        return urlRequest
    }
}
