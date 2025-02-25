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
    func loadMainViewPosts(forCategory category:ItemCategory) ->  Task<[PostItem], Error>
}

final class MainViewDataLoader: MainViewDataLoading {
    
    //typealias ResultPublisher = AnyPublisher<[ItemCategory : [PostItem]], any Error>
    
    let requestService: any RequestingService
    
    init(service:some RequestingService) {
        requestService = service
    }
   
    
    func loadMainViewPosts(forCategory category:ItemCategory) -> Task<[PostItem], Error> {
        
        return Task {
            do {
                let itemsRequest = try MainViewDataRequestBuilder.buildRequestFor(category: category, resultType: CategoryItemsResponse.self)
                
                do{
                    
                    let responsePerCategory:CategoryItemsResponse = try await requestService.request(itemsRequest) as! CategoryItemsResponse //force unwrap will break if the response decoded value changes. This ensures that testing will reveal some problems early
                    
                    logger.notice("Finished loading posts info for \"\(category.name)\"")
                    
                    return responsePerCategory.items
                }
                catch (let loadingError) {
#if DEBUG
                    print("Error loading posts per category: \(category.name): \(loadingError)")
#endif
                    throw loadingError
                }
                
                
            }
            catch (let requestBuildingError) {
#if DEBUG
                print("\(#function) Request Building Error: \(requestBuildingError)")
                throw requestBuildingError
#endif
            }
        }
    }
    
    
    
}
