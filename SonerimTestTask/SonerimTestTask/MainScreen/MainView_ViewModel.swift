//
//  MainView_ViewModel.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation


final class MainViewViewModel {
    
    let model:MainViewModel
    
    init(categories:[ItemCategory], dataLoader loader: some MainViewDataLoading, imagesSource: ImageCache) {
        model = MainViewModel(categories: categories, dataLoader: loader, imagesCache: imagesSource)
    }
    
    func onViewAppear() {
        if loadedPosts.isEmpty {
            startLoadingData()
        }
    }
    
    func onPostAppear(_ postId:String, in category:ItemCategory) {
        model.checkImageForPost(postId, inCategory:category)
    }
    
    func uiSelectPost(_ post:PostInfo, in category:ItemCategory) {
        
    }
}

extension MainViewViewModel {
    var categories:[ItemCategory] {
        model.categories
    }
    
    var loadedPosts:[ItemCategory:[PostInfo]] {
        model.loadedPosts
    }
    
    var isLoading:Bool {
        model.isLoading
    }
}

extension MainViewViewModel {
    private func startLoadingData() {
        model.startLoadingData()
    }
}


