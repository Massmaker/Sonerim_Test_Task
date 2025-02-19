//
//  ContentView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 18.02.2025.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var rootModel:RootModel
    
    @State private var selectedPostDetail:PostInfo?
    
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
        
        if let selectedPostDetail {
            FlickPostDetailsView(post: selectedPostDetail)
        }
        else {
            MainView(viewModel: rootModel.mainViewModel)
        }
    }
}

#Preview {
    @Previewable @State var selectedPost:PostInfo?
    
    RootView(rootModel: RootModel())
}
