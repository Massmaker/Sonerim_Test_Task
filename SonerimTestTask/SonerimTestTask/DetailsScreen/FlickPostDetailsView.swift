//
//  FlickPostDetailsView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import SwiftUI

struct FlickPostDetailsView: View {
    
    var post:PostInfo
    
    var body: some View {
        VStack {
            if let uiImage = post.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            else {
                Text("No Image")
                    .padding()
                    .background(in: RoundedRectangle(cornerRadius: 13))
                    
            }
           
            Text(post.title)
                .font(.title)
            
            Text(post.details)
                .font(.body)
        }
        .frame(maxWidth: .infinity, maxHeight:.infinity)
        
    }
}

#Preview {
    FlickPostDetailsView(post: PostInfo(title: "Post title", details: "re-record Delicate fuck the patriarchy cats quill indie surprise 22 stained glass windows in my mind merch debut Grammy no, it's becky song stadium Red twang guitar (10 Minute Version) casette Elvira soft i had a marvelous time ruining everything august pop here's how Cruel Summer can still be a single snake Red you need to calm down producer", image: nil, id: "https://live.staticflickr.com/65535/54335630356_ed0d540d24_m.jpg"))
}
