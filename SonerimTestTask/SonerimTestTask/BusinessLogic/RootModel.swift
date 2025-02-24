//
//  RootModel.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation
import Observation
import UIKit
import SwiftUI

@MainActor
@Observable
final class RootModel {
    
    var postDetails:PostDetails?
    var categories:[ItemCategory]
    var playerStatus:PlayerStatus = .init()
    
    @ObservationIgnored private var imageCache:ImageCache // actor
    @ObservationIgnored private var postsStore:PostsDataCache //actor
    
    @ObservationIgnored lazy var mainViewModel:MainViewViewModel = {
        
        let mainModel = Factory.createMainModel(forCategories: categories,
                                                postDataStore: postsStore,
                                                imageCache: imageCache)
        
        mainModel.setPostForCategoryHandler {[unowned self] category, selectedPostInfo in
            
            let image = selectedPostInfo.image ?? UIImage(named: "DummyImage")!
            
            Task {[image] in
                
                do {
                    let storedPostData = try await postsStore.postItem(inCategory: category, forPostInfo: selectedPostInfo)
                    withAnimation{
                        self.postDetails = PostDetails(title: storedPostData.title, image: image, detailsContainer: storedPostData)
                    }
                    
                }
                catch (let postsStoreError) {
#if DEBUG
                    print("Error finding tapped post: \(postsStoreError)")
#endif
                }
            }
        }
        
        let viewModel = MainViewViewModel(model: mainModel)
        
        return viewModel
    }()
    
    init() {
        
        var categories:[ItemCategory] = []
        
        if let url = Bundle.main.url(forResource: "DefaultCategoriesList", withExtension: "plist") {
            do {
                let data = try Data(contentsOf: url)
                
                let plistDecoder = PropertyListDecoder()
                
                let info = try plistDecoder.decode(BundleCategories.self, from: data)
                
                let validCategories:[ItemCategory] = info.categories
                    .filter({!$0.isEmpty})
                    .compactMap({ItemCategory(name: $0)})
                
                categories = validCategories
            }
            catch {
#if DEBUG
                print("Failed loading of the Default Categories: \(error)")
#endif
            }
        }
        
        self.categories = categories
        
        let requestsService = Factory.createRequestsService()
        
        let mainViewDataLoader = MainViewDataLoader(service: requestsService)
        
        self.imageCache = ImageCache(service: requestsService)
        self.postsStore = PostsDataCache(categories: categories, loader: mainViewDataLoader)
    }
}

extension RootModel {
    func postDetailsGoHomeAction() {
        withAnimation{
            self.postDetails = nil
        }
        
    }
}

fileprivate class Factory {
    @MainActor
    static func createMainModel(forCategories categories:[ItemCategory],
                                postDataStore: some PostsDataStore,
                                imageCache: some DataForURLCache) -> MainViewModel {
        
        let mainModel = MainViewModel(categories: categories,
                                      dataCache: postDataStore,
                                      imagesCache: imageCache) { _, _ in
            
        }
        
        return mainModel
    }
    
    static func createURLSession() -> URLSession {
        let aURLSession = URLSession(configuration: .default)
        return aURLSession
    }
    
    static func createRequestsService() -> URLSessionRequestService {
        let session = createURLSession()
        let jsonDecoder = newJSONDecoder()
        let requestsService = URLSessionRequestService(session: session, decoder: jsonDecoder)
        
        return requestsService
    }
}


fileprivate struct BundleCategories:Decodable {
    var categories:[String]
}
