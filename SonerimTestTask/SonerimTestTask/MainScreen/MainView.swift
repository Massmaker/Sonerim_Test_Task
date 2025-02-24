//
//  MainView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import SwiftUI

struct MainView: View {
    
    let viewModel:MainViewViewModel
    
    var body: some View {
        ZStack {
            // a background taking full screen
            Color.accentColor
                .opacity(0.5)
                .ignoresSafeArea(edges:[.bottom, .top])
            
            ScrollView(.vertical) {
                Spacer(minLength: 1)
                
                LazyVStack(spacing: 32) {
                    ForEach(viewModel.categories, id: \.name) { aCat in
                        let posts = viewModel.loadedPosts[aCat] ?? []
                        PostsHorizontalView(category: aCat,
                                            posts: posts,
                                            postSelection: {
                            viewModel.uiSelectPost($0, in: aCat)
                        }) { postId, category in
                            viewModel.onPostAppear(postId, in: category)
                        }
                        
                    }
                }
                
                Spacer(minLength: 1)
                
            }//end vertical scroll
            
            
        }
        
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: {
                viewModel.onViewAppear()
            })
            
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(.circular)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}
