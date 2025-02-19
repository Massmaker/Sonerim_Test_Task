//
//  MainView_Model.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Combine
import Observation
import UIKit

@Observable
final class MainViewModel {
    
    private(set) var categories:[ItemCategory]
    
    let dataLoader: any MainViewDataLoading
    let imageCache:ImageCache
    private(set) var loadedPosts:[ItemCategory:[PostInfo]] = [:]
    private(set) var isLoading:Bool = false
    private var dataLoadingCancellable:AnyCancellable?
    
    init(categories: [ItemCategory], dataLoader loader: some MainViewDataLoading, imagesCache cache:ImageCache) {
        self.categories = categories
        self.dataLoader = loader
        self.imageCache = cache
    }
    
    func startLoadingData() {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        
        Task {
            let loadedInfo = await dataLoader.loadMainViewPosts(forCategories: categories)
            var result = [ItemCategory:[PostInfo]]()
            
            for (category, posts) in loadedInfo {
                
                let uiPosts = posts.map({ item in
                    return PostInfo(title: item.title, details: item.description, id: item.media.m)
                })
                
                result[category] = uiPosts
            }
            
            self.loadedPosts = result
            isLoading = false
        }
         
    }
    
    func checkImageForPost(_ postId:String, inCategory category:ItemCategory) {
        Task {
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
    
//    private func spawnImageLoading(forPostId postId:String, in category:ItemCategory) {
//        
//        Task(priority: .low) {[postId] in
//            guard let imageData = await imageCache.readData(forLink: postId) else {
//                return
//            }
//            
//            if let indexInArray = loadedPosts[category]?.firstIndex(where: {$0.id == postId}),
//                let post = loadedPosts[category]?[indexInArray] {
//                post.image = UIImage(data:imageData)
//            }
//        }
//    }
    
}
