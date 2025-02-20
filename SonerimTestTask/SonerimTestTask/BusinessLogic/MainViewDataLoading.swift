//
//  MainViewDataLoader.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation
import Combine
import OSLog
#if DEBUG
fileprivate let logger = Logger(subsystem: "DataLoading", category: "MainViewDataLoader")
#else
fileprivate let logger = Logger(.disabled)
#endif
protocol MainViewDataLoading {
    
    func loadMainViewPosts(forCategories categories:[ItemCategory]) async -> [ItemCategory:[PostItem]]
}


actor MainViewDataLoader: MainViewDataLoading {
    
    typealias ResultPublisher = AnyPublisher<[ItemCategory : [PostItem]], any Error>
    
    let requestService: any RequestingService
    
    init(service:some RequestingService) {
        requestService = service
    }
    
    /// - Returns:  [ItemCategory:[PostItem]]
    func loadMainViewPosts(forCategories categories:[ItemCategory]) async -> [ItemCategory:[PostItem]] {
        
        var results:[ItemCategory:[PostItem]] = [:]
        
        for aCat in categories {
            
            do {
                let itemsRequest = try MainViewDataRequestBuiilder.buildRequestFor(category: aCat, resultType: CategoryItemsResponse.self)
                    
                do{
                    let responsePerCategory = try await requestService.request(itemsRequest)
                    logger.notice("Finished loading posts info for \"\(aCat.name)\"")
                    if let response = responsePerCategory as? CategoryItemsResponse {
                        
                        if !response.items.isEmpty {
                            results[aCat] = response.items
                        }
                    }
                }
                catch (let loadingError) {
#if DEBUG
                    print("Error loading posts per category: \(aCat.name): \(loadingError)")
#endif
                }
                
            }
            catch (let requestBuildingError) {
#if DEBUG
                print("\(#function) Request Building Error: \(requestBuildingError)")
#endif
            }
        }
        
        
        
        
        return results
    }
    
}
