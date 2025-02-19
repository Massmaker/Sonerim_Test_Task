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
                .font(.title3)
            
            ScrollView(.horizontal, content: {
                
                
                LazyHStack(spacing:16) {
                    
                    ForEach(posts, content: { aPost in
                        VStack {
                            if let image = aPost.image {
                                Image(uiImage:image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:100, height:100, alignment:.center)
                                    .clipped()
                                    .contentShape(Rectangle())
                                    
                            }
                            else {
                                Image(systemName: "circle.square")
                                    .resizable()
                                    .frame(maxWidth:100, maxHeight:80)
                                    .aspectRatio(contentMode: .fit)
                            }
                            
                            Spacer()
                            Text(aPost.title)
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .lineLimit(3)
                            Spacer()
                        }
                        .frame(width:100)
                        .frame(maxHeight:170)
                        .border(Color.secondary, width: 1)
                        .onTapGesture {
                            postSelection(aPost)
                        }
                        
                        .onAppear {
                            onPostAppear(aPost.id, category)
                        }
                        
                        
                    })
                        
                    Spacer(minLength: 8)
                }
                
                
                
            })
        }
        
        .frame(height:170)
        
        
        
    }
}

#Preview {
    
    PostsHorizontalView(category: ItemCategory(name: "Test Category")!, posts: PostInfo.dummies, postSelection: {_ in}, onPostAppear: { _, _ in })
}
