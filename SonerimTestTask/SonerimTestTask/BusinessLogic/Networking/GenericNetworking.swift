//
//  GenericRequest.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 25.02.2025.
//

import Foundation

//MARK: -
protocol Request {
    var method:String {get}
    var path:String {get}
    var parameters:[String:String] {get}
    var headers:[String:String] {get}
    var body:Data? {get}
    associatedtype SuccessType:Decodable
}

protocol Response {
    var statusCode:Int {get}
}

protocol Session {
    func data<T:Request>(for request: T) async throws -> (Data, Response)
}

protocol RequestingService {
    func request<RequestType:Request>(_ request: RequestType) async throws -> RequestType.SuccessType
    func requestDataFor<RequestType:Request>(_ request: RequestType) async throws -> Data
}

//MARK: -

