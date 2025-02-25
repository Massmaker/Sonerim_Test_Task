//
//  MainView_Model.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//


import Observation
import UIKit

typealias PostForCategoryHandler = (ItemCategory, PostInfo) ->()

protocol PostForCategoryHandlerSettable {
    func setPostForCategoryHandler(_ handler:@escaping PostForCategoryHandler) async
}

import OSLog
#if DEBUG
fileprivate let logger = Logger(subsystem: "Model", category: "MainViewModel")
#else
fileprivate let logger = Logger(.disabled)
#endif

@MainActor
@Observable
final class MainViewModel {
    //MARK: Dependencies
    private(set) var categories:[ItemCategory]
    @ObservationIgnored
    let postsCache: any PostsDataStore
    @ObservationIgnored
    let imageCache: any DataForURLCache
    @ObservationIgnored
    private(set) var postSelectionHandler: PostForCategoryHandler = {category, selectedPost  in
        
    }
    
    //MARK: private properties
    private(set) var loadedPosts:[ItemCategory:[PostInfo]] = [:]
    private(set) var isLoading:Bool = false
    
    //some lazy "Is Loading" handling
    private var pendingTasksCount:Int = 0 {
        didSet {
            if pendingTasksCount < 1 && isLoading {
                isLoading = false
            }
        }
    }
    
    init(categories: [ItemCategory],
         dataCache postsCache: some PostsDataStore,
         imagesCache cache: some DataForURLCache,
         postSelectionHandler selectionHandler: @escaping PostForCategoryHandler) {
        self.categories = categories
        self.postsCache = postsCache
        self.imageCache = cache
        
        self.postSelectionHandler = selectionHandler
    }
    
    func startLoadingData() {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        
        pendingTasksCount = categories.count
        
        for category in categories {
            
            
            let task = Task {
                do {
                    let posts = try await postsCache.postItems(inCategory: category)
                    self.loadedPosts[category] = posts.map({ postItem in
                        PostInfo(title: postItem.title, mediaURLString: postItem.media.m)
                    })
                }
                catch (let loadingError) {
                    logger.error("Failed to load posts for '\(category.name)': \(loadingError)")
                }
                
                pendingTasksCount -= 1 // potentially could data race, but in real world URLRequests responses handling decreasig an Int takes really no time
            }
            
            
        }
    }
    
    func checkImageForPost(_ postId:String, inCategory category:ItemCategory) {
        
        
        Task(priority: .low) {
            if let indexInArray = loadedPosts[category]?.firstIndex(where: {$0.id == postId}),
                let post = loadedPosts[category]?[indexInArray] {
                if post.image == nil {
                    guard let imageData = await imageCache.readData(forLink: postId) else {
                        return
                    }
                    guard let image = UIImage(data: imageData) else {
                        return
                    }
                    post.image = image
                }
            }
        }
    }
    
    func selectPost(_ post:PostInfo, inCategory category:ItemCategory) {
        postSelectionHandler(category, post)
    }
    
}

extension MainViewModel: PostForCategoryHandlerSettable {
    func setPostForCategoryHandler(_ handler:@escaping PostForCategoryHandler) {
        postSelectionHandler = handler
    }
}
