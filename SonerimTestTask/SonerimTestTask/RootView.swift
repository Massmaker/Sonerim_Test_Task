//
//  ContentView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 18.02.2025.
//

import SwiftUI

struct RootView: View {
    
    let rootModel:RootModel
    
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
        
        if let details = rootModel.postDetails {
            if #available(iOS 18.0, *) {
                FlickPostDetailsView(image: details.image,
                                     title: details.title,
                                     postData: details.detailsContainer,
                                     dismissAction: rootModel.postDetailsGoHomeAction)
            } else {
                // Fallback on earlier versions
                PreiOS18DetailsView()
            }
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
