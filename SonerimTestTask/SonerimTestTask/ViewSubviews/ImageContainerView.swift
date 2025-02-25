//
//  ImageContainerView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 21.02.2025.
//

import SwiftUI

struct ImageContainerView: View {
    let image:UIImage
    var largeImageURL:URL?
    
    var body: some View {
        
        if let largeImageURL {
            
            AsyncImage(url: largeImageURL, scale: 2.0) { phase in
                switch phase {
                case .empty:
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:// (let error):
                    placeHolder
                    //we can display some error for loading the full size image if needed:
                        .overlay(alignment: .bottomTrailing, content: {
                        
                            Text("Error loading large image")
                                .font(.caption2)
                                .foregroundStyle(Color.red)
                                .foregroundStyle(.secondary)
                                .padding([.bottom, .trailing], 4)
                        })
                @unknown default:
                    placeHolder
                }
            }
            
        }
        else {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        
    }
    
    var placeHolder:some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    ImageContainerView(image: UIImage(named: "DummyImage")!, largeImageURL: URL(string: "https://live.staticflickr.com/65535/54335630356_ed0d540d24_g.jpg")!)
}
