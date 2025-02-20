//
//  MainView_Model.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Combine
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
    private(set) var postSelectionHandler: PostForCategoryHandler
    
    //MARK: private properties
    private(set) var loadedPosts:[ItemCategory:[PostInfo]] = [:]
    private(set) var isLoading:Bool = false
    @ObservationIgnored
    private var dataLoadingCancellable:AnyCancellable?
    
    init(categories: [ItemCategory],
         dataCache postsCache: some PostsDataStore,
         imagesCache cache: some DataForURLCache,
         postSelectionHandler selectionHandler: @escaping PostForCategoryHandler) {
        self.categories = categories
        self.postsCache = postsCache
        self.imageCache = cache
        
        self.postSelectionHandler = selectionHandler
        subscribeForDataLoading()
    }
    
    private func subscribeForDataLoading() {
        dataLoadingCancellable =
        postsCache.dataPublisher.eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            
            .sink {[weak self] compl in
                guard let self, case .failure(let error) = compl else {
                    return
                }
                
                //TODO: Handle possible loading errors if needed
                
                logger.warning("Error Loading Posts info: \(error)")
                
                if self.isLoading {
                    self.isLoading = false
                }
                
            } receiveValue: { [weak self] loadedItems in
                guard let self else {
                    return
                }
                
                if self.isLoading {
                    logger.notice("Finished loading Post Items")
                }
                
                var result = [ItemCategory:[PostInfo]]()
                
                for (category, posts) in loadedItems {
                    
                    let uiPosts = posts.map({ item in
                        return PostInfo(title: item.title, id: item.media.m)
                    })
                    
                    result[category] = uiPosts
                }
                
                self.loadedPosts = result
                
                if self.isLoading {
                    self.isLoading = false
                }
            }
        
    }
    
    func startLoadingData() {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        
        postsCache.startLoading()
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
