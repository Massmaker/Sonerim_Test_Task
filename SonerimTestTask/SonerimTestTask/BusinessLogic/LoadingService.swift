//
//  Sessions.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation




final class URLSessionRequestService:RequestingService {
    
    private let session:Session
    
    private let decoder:JSONDecoder
    
    init(session: some Session = URLSession(configuration:.default), decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    /// - Returns: required SuccessType decoded from the URLResponse's  Data
    func request<RequestType: Request>(_ request: RequestType) async throws -> RequestType.SuccessType {
        
        let data = try await requestDataFor(request)
        
        do {
            let type = type(of:request).SuccessType
            do {
                let result = try decoder.decode(type, from: data)
                return result
            }
            catch (let decodingError) {
                throw RequestingServiceError.decodingFailed(decodingError)
            }
        }
        catch(let urlSessionError) {
            throw urlSessionError
        }
        
    }
    
    /// - Returns: Raw Data from the URLResponse if status code is 200...299
    func requestDataFor<RequestType:Request>(_ request: RequestType) async throws -> Data {
//        let urlRequest = try request.asURLRequest()
        
        do {
            let (data, response) = try await session.data(for: request)
            let code = response.statusCode
            guard code / 100 == 2 else { //something in range 200...299
                throw ResponseError.invalidStatusCode(code)
            }
            
            return data
        }
        catch(let urlSessionError) {
            throw urlSessionError
        }
    }
    
}



extension HTTPURLResponse:Response {} //statusCode

extension URLSession:Session {
    func data<T>(for request: T) async throws -> (Data, any Response) where T : Request {
        let urlRequest = try request.asURLRequest()
        
        let (data, response) = try await self.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResponseError.invalidResponse(response)
        }
        
        return (data,httpResponse)
    }
    
}



protocol ConvertibleToURLRequest {
    func asURLRequest() throws -> URLRequest
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
