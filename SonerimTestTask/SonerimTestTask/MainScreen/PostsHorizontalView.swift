//
//  PostsHorizontalView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import SwiftUI

struct PostsHorizontalView: View {
    let category:ItemCategory
    var posts:[PostInfo]
    var postSelection: (PostInfo) -> ()
    var onPostAppear:  (String, ItemCategory) -> ()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(category.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal) {
                    LazyHStack {
                        
                        ForEach(posts,
                                content: { aPost in
                            
                                PostItemCellView(
                                    image: aPost.image,
                                    title: aPost.title
                                )
                                .frame(width:100)
                                
                                .onTapGesture {
                                    postSelection(aPost)
                                }
                                .onAppear {
                                    onPostAppear(aPost.id,category)
                                }
                                //.border(Color.green)
                                //.padding(.horizontal)
                        })
                        
                    }
                    .frame(maxHeight:190)
                    .overlay(content:{
                        Rectangle()
                            .stroke(Color.primary, lineWidth: 1.0)
                    })
            }
           
        }
        .frame(height:190)
        
        
        
    }
}

#Preview {
    
    PostsHorizontalView(category: ItemCategory(name: "Test Category")!, posts: PostInfo.dummies, postSelection: {_ in}, onPostAppear: { _, _ in })
}
