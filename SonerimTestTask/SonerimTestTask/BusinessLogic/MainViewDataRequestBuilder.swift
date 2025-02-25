//
//  MainViewDataRequestBuiilder.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation





fileprivate let base:String = "https://api.flickr.com"

final class MainViewDataRequestBuilder {
    struct GetMainViewDataRequest<SuccessType> : Request {
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
}

extension MainViewDataRequestBuilder {
    
    /// - Returns: - GetMailViewDataRequest<>
    static func buildRequestFor<Result>(category:ItemCategory, resultType: Result.Type) throws -> some Request where Result:Decodable  {
        guard let aURL = URL(string: base) else {
            throw URLError(.badURL)
        }
        
        let appendedPathString = aURL.appending(path: "/services/feeds/photos_public.gne", directoryHint: .notDirectory)
            .absoluteString
        
        //using only the new APIs for making URLQueryItems
        let parameters = ["format": "json", "nojsoncallback":"1", "tags": category.name]
        
        let aRequest = GetMainViewDataRequest<Result.Type>(path: appendedPathString,
                                              parameters: parameters, requestMethod: .get)
        
        return aRequest
    }
    
    
    
}

extension MainViewDataRequestBuilder {
    /**
        - Returns: a GetImageDataRequest<Data> request
     */
    static func buildRequestForImage(with link:Link) throws -> some Request {
        let aRequest = GetImageDataRequest<Data>(path: link)
        return aRequest
    }
}


