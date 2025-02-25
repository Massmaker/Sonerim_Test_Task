//
//  ImageCache.swift
//  TestTask
//
//  Created by Ivan Yavorin on 06.02.2025.
//

import Foundation
import UIKit


typealias Link = String

protocol DataForURLCache {
    func readData(forLink link:Link) async -> Data?
}


actor ImageCache : DataForURLCache {
    
    enum ImageLoadingState {
        case inProgress(Task<Data?, Never>)
        case completed(Data)
    }
    
    private var cache:[Link:ImageLoadingState] = [:]
    
    let loadingService: any RequestingService
    
    init(service:some RequestingService) {
        loadingService = service
    }
    
    func readData(forLink link:Link) async -> Data? {
        
        if case let .inProgress(task) = cache[link] {
            return await task.value
        }
        
        if case let .completed(data) = cache[link] {
            return data
        }
        
        let loadingTask = Task<Data?, Never> {
            guard let data = try? await loadData(for: link) else {
                return nil
            }
            
            return data
        }
        
        cache[link] = .inProgress(loadingTask)
        
        guard let taskResultData = await loadingTask.value else {
            return nil
        }
        
        cache[link] = .completed(taskResultData)
        
        return taskResultData
    }
    
    private func loadData(for link:Link) async throws -> Data {
        
        let request = try MainViewDataRequestBuilder.buildRequestForImage(with: link)
//        print("Loading image")
        let imageData = try await loadingService.requestDataFor(request)
//        print("Loaded image")
        return imageData
    }
}
