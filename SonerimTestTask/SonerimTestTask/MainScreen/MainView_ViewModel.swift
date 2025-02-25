//
//  MainView_ViewModel.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation

@MainActor
final class MainViewViewModel {
    
    let model:MainViewModel
    
    init(model:MainViewModel ) {
        self.model = model
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
        model.selectPost(post, inCategory: category)
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


