//
//  FlickPostDetailsView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import SwiftUI

struct FlickPostDetailsView: View {
    /// Supply the default image if no image for a post is present
    let image:UIImage
    let title:String
    var postData:[(title:String, value:String)]
    private var largeImageURL:URL?
    var goHomeAction:() -> ()
    
    init(image: UIImage, title: String, postData: PrintableSortedValuesContainer, dismissAction action:@escaping () -> () ) {
        self.image = image
        self.title = title
        
        let postData = postData.printableSortedValues
            .filter({$0.0 != "title"})//fast hack to remode the "title: " description item under the main Title
        
        if let string = postData.first(where: { (title: String, value: String) in
            title == "_largeImage_"
        })?.1,
           let url = URL(string:string) {
            self.largeImageURL = url
        }
                         
        self.postData = postData
        self.goHomeAction = action
    }
    var body: some View {
        VStack(spacing: 16) {
            if let largeImageURL {
                AsyncImage(url: largeImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }

            }
            else {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            
            ScrollView {
                VStack (alignment: .leading) {
                    
                    Text(title)
                        .font(.title)
                        .padding()
                    
                    ForEach(postData, id: \.0, content: { info in
                        HStack {
                            Text("\(info.0) :")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(info.1)
                                .font(.body)
                        }
                        .padding()
                    })
                    
                    
                    
                    
                    
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight:.infinity)
        .toolbar {
            ToolbarItem(placement: .bottomBar, content: {
                Button(action:{
                    goHomeAction()
                },
                       label: {Text("Home")})
                    
                Spacer()
            })
        }
        
    }
}

#Preview {
    FlickPostDetailsView(image: UIImage(named: "DummyImage")!, title: PostItem.dummy1.title, postData: PostItem.dummy1, dismissAction: {})
}
