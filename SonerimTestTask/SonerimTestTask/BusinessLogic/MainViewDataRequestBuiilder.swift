//
//  MainViewDataRequestBuiilder.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
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

struct GetMailViewDataRequest<SuccessType> : Request {
    typealias SuccessType = CategoryItemsResponse
    
    private(set) var path: String
    
    private(set) var parameters: [String : String]
    
    private(set) var headers: [String : String] = [:]
    
    let requestMethod: RequetsMetod
    
    var body:Data? = nil
    
    var method:String {
        requestMethod.rawValue
    }
}

enum RequetsMetod:String {
    case get = "GET"
}

struct GetImageDataRequest<SuccessType>:Request {
    typealias SuccessType = Data
    private(set) var path: String
    
    private(set) var parameters: [String : String] = [:]
    
    private(set) var headers: [String : String] = [:]
    var body:Data? = nil
    var method: String = RequetsMetod.get.rawValue
}

fileprivate let base:String = "https://api.flickr.com"

final class MainViewDataRequestBuiilder {
    
    /// GetMailViewDataRequest<>
    static func buildRequestFor<Result>(category:ItemCategory, resultType: Result.Type) throws -> some Request where Result:Decodable  {
        guard let aURL = URL(string: base) else {
            throw URLError(.badURL)
        }
        
        let appendedPathString = aURL.appending(path: "/services/feeds/photos_public.gne", directoryHint: .notDirectory)
            .absoluteString
        
        //using only the new APIs for making URLQueryItems
        let parameters = ["format": "json", "nojsoncallback":"1", "tags": category.name]
        
        let aRequest = GetMailViewDataRequest<Result.Type>(path: appendedPathString,
                                              parameters: parameters, requestMethod: .get)
        
        return aRequest
    }
    
    
    
}

import UIKit
extension MainViewDataRequestBuiilder {
    /**
        
     Corners cut to speedup development
     
        - Returns: a GetImageDataRequest<UIImage> request
     */
    static func buildRequestForImage(with link:Link) throws -> some Request {
        let aRequest = GetImageDataRequest<Data>(path: link)
        return aRequest
    }
}


