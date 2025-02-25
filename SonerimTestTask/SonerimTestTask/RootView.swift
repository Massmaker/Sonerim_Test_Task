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

        if let details = rootModel.postDetails {
            
                FlickPostDetailsView(image: details.image,
                                     title: details.title,
                                     postData: details.detailsContainer,
                                     mediaURLContainer: details.detailsContainer,
                                     dismissAction: rootModel.postDetailsGoHomeAction)
                .environment(rootModel.playerStatus)
                .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top)))
           
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
