//
//  Errors.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation
enum LogicError:Error {
    case emptyInputValue
}

enum SearchError:Error {
    case notFound
}

enum ResponseError:Error {
    case invalidStatusCode(Int)
    case invalidResponse(URLResponse)
}


enum RequestingServiceError:Error {
    case decodingFailed(Error?)
}
