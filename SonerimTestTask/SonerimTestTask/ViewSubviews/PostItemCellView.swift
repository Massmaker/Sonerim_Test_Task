//
//  PostItemCellView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 20.02.2025.
//

import SwiftUI

struct PostItemCellView: View {
    
    var image:UIImage?
    let title:String
    
    var body: some View {
        VStack(spacing:16) {
            
            imageView
                .padding(.top, 8)
            
            Text(title)
                .foregroundStyle(.secondary)
                .font(.caption)
                .lineLimit(3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 4)
        }
    }
    
    @ViewBuilder private var imageView: some View {
        if let image {
            Image(uiImage:image)
                .resizable()
                .scaledToFill()
                .frame(width:90, height: 90)
                .clipped()
                .contentShape(Rectangle())
                
        }
        else {
            Image(systemName: "circle.square")
                .resizable()
                .scaledToFill()
                .frame(width:90, height: 90)
        }
    }
}

#Preview {
    ScrollView(.horizontal, content: {
        
        LazyHStack(spacing: 16, content: {
            PostItemCellView(image:nil, title: "Test title long string")
            .frame(width: 100, height:170)
            .border(Color.secondary)
            
            PostItemCellView(image:nil, title: "Test title long string")
            .frame(width: 100, height:170)
            .border(Color.secondary)
        })
            
    })
    
    
}
