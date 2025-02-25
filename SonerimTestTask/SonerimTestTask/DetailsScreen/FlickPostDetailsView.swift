//
//  FlickPostDetailsView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import SwiftUI

fileprivate struct TitleID:Hashable {
    let text:String
}

@available(iOS 18.0, *)
struct FlickPostDetailsView: View {
    /// Supply the default image if no image for a post is present
    let image:UIImage
    let title:String
    var postData:[(title:String, value:String)]
    private var largeImageURL:URL?
    var goHomeAction:() -> ()
    
    
    //MARK: - properties
    //MARK: Handle Main Scroll
    @State private var naturalOffset: CGSize = .zero
    @State private var isScrolling:Bool = false
    @State private var imageSize:CGSize = CGSize(width: 1, height: 1)
    @State private var imageOpacity:CGFloat = 1.0
    
    //MARK: Handle Player presentation
    @Environment(PlayerStatus.self) var playerStatus

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    //MARK: -
    init(image: UIImage, title: String,
         postData: some PrintableSortedValuesContainer,
         mediaURLContainer: some MediaURLsContainer,
         dismissAction action:@escaping () -> () ) {
        
        self.image = image
        self.title = title
        
        let printableData = postData.printableSortedValues
            
        
        let string = mediaURLContainer.mediaURLString
        if !string.isEmpty, let url = URL(string:string) {
            self.largeImageURL = url
        }
                         
        self.postData = printableData
        self.goHomeAction = action
    }
    
    var body: some View {
        ZStack(alignment:.bottom) {
            if case .compact = verticalSizeClass {
                ImageContainerView(image: image, largeImageURL: largeImageURL)
                    .shadow( radius: 10.0)
            }
            else {
                scrollableVerticalContent
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            bottomButtonsContainer
        })
    }
    
    @ViewBuilder private var scrollableVerticalContent: some View {
        ScrollView {
            
            ImageContainerView(image: image, largeImageURL: largeImageURL)
                .background(
                    GeometryReader(content: { proxy in
                        let frame = proxy.frame(in: .named("ScrollViewSpace"))
                        Color.clear
                            .preference(key: ViewSizeKey.self, value: frame.size)
                    })
                )
                .onPreferenceChange(ViewSizeKey.self, perform: {newSize in
                    imageSize = newSize
                })
                .offset(naturalOffset)
                .opacity(imageOpacity)
                .zIndex(1) //keep the Image view under the text for it to be scrolled over the Image
            
            scrollableContent
                .zIndex(1000)//keep the text above the image when scrolled towards the top
            
        }
        .coordinateSpace(name:"ScrollViewSpace")
        .onScrollGeometryChange(for: CGFloat.self,
                                    of: { scrollGeoProxy in
            scrollGeoProxy.contentOffset.y
        },
                                    action: { oldValue, newValue in
            //keep the image header always at the top
            naturalOffset = imageOffset(for: newValue)
            
            // adjust opacity from 0.7 to 1.0 when the text is scrolled upwards
            imageOpacity = imageOpacity(forOffset: newValue)
        })
        .onScrollPhaseChange({ oldPhase, newPhase in
            // Optional:
            // adjust the bottom buttons horizontal view opacity for scrolling behaviour:
            
            if case .interacting = newPhase {
                withAnimation(.linear(duration: 0.2)) {
                    isScrolling = true
                }
                return
            }
            
            if case .decelerating = newPhase {
                withAnimation(.easeIn(duration:0.2)) {
                    isScrolling = false
                }
                return
            }
            if case .idle = newPhase {
                isScrolling = false
            }
            
        })
        .ignoresSafeArea(.container, edges: .top)
        
        
        //this is needed due to the Apple's new "Observation" framework and data updates monitoring/handling
        @Bindable var status = playerStatus
        
        if playerStatus.isPlayerVisible {
            
            
            PlayerContainerView(title: "Song Title Here",
                                details: "Some Long Details for song HERE Some Long Details for song HERE Some Long Details for song HERE Some Long Details for song HERE. ng HERE Some Long Details for song HERE Some Long Details for song HERE",
                                playerProgress: $status.playerProgress)
            .transition(.move(edge: .bottom))
//                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)) )
        }
    }
    
    @ViewBuilder
    private var scrollableContent: some View {
        
        VStack (alignment: .leading, spacing:16) {
            VStack {
                Text(title)
                    .font(.title)
                    .padding()
            }
            
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
    
    @ViewBuilder private var bottomButtonsContainer: some View {
        HStack(spacing:16) {
            Button(action:{
                goHomeAction()
            },
                   label: {Text("Home")})
            .buttonStyle(.bordered)
            //
            Button(action:{
                withAnimation {
                    playerStatus.isPlayerVisible.toggle()
                }
                
            },
                   label: {Text("Audio")}
            )
            .buttonStyle(.bordered)
            //move buttons to the leading edge
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        //.ignoresSafeArea(edges:.bottom)
        .background(.ultraThinMaterial)
        .opacity(isScrolling ? 0.6 : 1.0)
    }
    
    private func imageOpacity(forOffset offset:CGFloat) -> CGFloat {
        return min(1.0, max(0.7, (imageSize.height - naturalOffset.height) / imageSize.height))
    }
    
    private func imageOffset(for value:CGFloat) -> CGSize {
        return CGSize(width:0, height: value)
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        FlickPostDetailsView(image: UIImage(named: "DummyImage")!,
                             title: PostItem.dummy1.title,
                             postData: PostItem.dummy1,
                             mediaURLContainer: PostItem.dummy1,
                             dismissAction: {})
        .environment(PlayerStatus())
    } else {
        // Fallback on earlier versions
        Text("pre iOs 18 view")
    }
}


struct ViewOffsetKey:PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ViewSizeKey:PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let nextSize = nextValue()
        value.width += nextSize.width
        value.height += nextSize.height
    }
}


//MARK: -

