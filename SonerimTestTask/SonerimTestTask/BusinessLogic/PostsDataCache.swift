//
//  PostsDataCache.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 20.02.2025.
//

import Foundation
import Combine

protocol PostsDataStore {
    func postItems(inCategory cat:ItemCategory) async throws -> [PostItem]
}
 
enum PostsProgress {
    case inProgress(Task<[PostItem], Error>)
    case ready([PostItem])
}

final class ProgressEnumContainer {
    var wrapped:PostsProgress
    init(_ wrapped: PostsProgress) {
        self.wrapped = wrapped
    }
}


actor PostsDataCache:PostsDataStore {
    
    private(set) var categories:[ItemCategory] {
        didSet {
            if oldValue != categories {
                dataCache.removeAllObjects()
            }
        }
    }
    
    let dataLoader: any MainViewDataLoading
    private var dataCache:NSCache<NSString,ProgressEnumContainer>
    
    private var isLoadingData:Bool = false
    
    
    init(categories: [ItemCategory],
         postsItemsLoaded: [ItemCategory : [PostItem]] = [:],
         loader: some MainViewDataLoading) {
        
        self.categories = categories
        self.dataCache = .init()
        self.dataLoader = loader
    }
    
    func postItems(inCategory cat:ItemCategory) async throws -> [PostItem] {
        
        if let progressContainer = dataCache[cat.name] {
            switch progressContainer.wrapped {
            case .ready(let postItems):
                return postItems
                
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        //start new loading query
        
        let newTask:Task<[PostItem], any Error> = Task {
            try await dataLoader.loadMainViewPosts(forCategory: cat).value
        }
        
        dataCache[cat.name] = ProgressEnumContainer(PostsProgress.inProgress(newTask))
        
        do {
            let loadedPosts =  try await newTask.value
            
            dataCache[cat.name] = ProgressEnumContainer(PostsProgress.ready(loadedPosts))
            
            return loadedPosts
        }
        catch(let loadingError) {
            dataCache[cat.name] = nil
            throw loadingError
        }
        
    }
}

