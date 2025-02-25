//
//  Sessions.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation

protocol RequestingService {
    func request<RequestType:Request>(_ request: RequestType) async throws -> RequestType.SuccessType
    func requestDataFor<RequestType:Request>(_ request: RequestType) async throws -> Data
}


final class URLSessionRequestService:RequestingService {
    
    private let session:URLSession
    
    private let decoder:JSONDecoder
    
    init(session:URLSession = URLSession(configuration:.default), decoder: JSONDecoder = JSONDecoder()) {
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
        let urlRequest = try request.asURLRequest()
        
        do {
            let (data, urlResponse) = try await session.data(for: urlRequest)
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw ResponseError.invalidResponse(urlResponse)
            }
            
            guard httpResponse.statusCode / 100 == 2 else { //something in range 200...299
                throw ResponseError.invalidStatusCode(httpResponse.statusCode)
            }
            
            return data
        }
        catch(let urlSessionError) {
            throw urlSessionError
        }
    }
    
}


protocol Session {
    associatedtype Request
    func data(for: Request) async throws -> Data?
}

