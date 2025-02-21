//
//  PostsDataCache.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 20.02.2025.
//

import Foundation
import Combine

protocol PostsDataStore {
    var dataPublisher: any Publisher<[ItemCategory:[PostItem]], any Error> { get }
    func startLoading()
}



actor PostsDataCache {
    
    private(set) var categories:[ItemCategory] {
        didSet {
            if oldValue != categories {
                cachedData.removeAll()
                startLoading()
            }
        }
    }
    
    let dataLoader: any MainViewDataLoading
    var cachedData: [ItemCategory:[PostItem]] {
        didSet {
            cvPublisher?.send(cachedData)
        }
    }
    private var isLoadingData:Bool = false
    private var cvPublisher:CurrentValueSubject<[ItemCategory:[PostItem]], Error>?
    
    init(categories: [ItemCategory],
         postsItemsLoaded: [ItemCategory : [PostItem]] = [:],
         loader: some MainViewDataLoading) {
        
        self.categories = categories
        self.cachedData = postsItemsLoaded
        self.dataLoader = loader
    }
    
    
    
    func postItem(inCategory cat:ItemCategory, forPostInfo postInfo:PostInfo) async throws -> PostItem {
        
        if let loadedItems = cachedData[cat],
           let firstIndex = loadedItems.firstIndex(where: {$0.postId == postInfo.id}) {
            
            let postItem = loadedItems[firstIndex]
            return postItem
        }
        
        throw SearchError.notFound
    }
}

extension PostsDataCache: @preconcurrency PostsDataStore {
    
    var dataPublisher: any Publisher<[ItemCategory:[PostItem]], any Error> {
        
        if let existing = cvPublisher {
            return existing
        }
        
        let cvPublisher = CurrentValueSubject<[ItemCategory:[PostItem]], Error>([ItemCategory : [PostItem]]())
        self.cvPublisher = cvPublisher
        
        return cvPublisher
    }
    
    func startLoading() {
        if isLoadingData {
            return
        }
        
        isLoadingData = true
        
        Task {
            let loadedData = await dataLoader.loadMainViewPosts(forCategories: categories)
            self.cachedData = loadedData
            isLoadingData = false
        }
    }
}
