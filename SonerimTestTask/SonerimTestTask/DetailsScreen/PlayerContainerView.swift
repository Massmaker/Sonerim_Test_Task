//
//  PlayerContainerView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 21.02.2025.
//

import SwiftUI

fileprivate let kMinimizedStateContentHeight:CGFloat = 100

struct PlayerContainerView: View {
    
    enum DragState:Equatable {
        case bottom
        case fraction(CGFloat)
        case top
        
        var dependentOpacity:CGFloat {
            if case .fraction(let value) = self {
                return value
            }
            
            if case .top = self {
                return 1.0
            }
            
            return 0.0
        }
        
        var dependentVerticalScale:CGFloat {
            if case .fraction(let value) = self {
                return value
            }
            
            if case .top = self {
                return 1.0
            }
            
            return 0.0
        }
        
        var backgroundOpacity:CGFloat {
            if case .fraction(let value) = self {
                return value
            }
            
            if case .top = self {
                return 0.5
            }
            
            return 0.02
        }
    }
    
    let title:String
    let details:String
    
    @Binding var playerProgress:CGFloat
    
    @State private var backgroundColor:Color = .black
    
    @State private var dragState:DragState = .bottom
    @State private var maxContentHeight:CGFloat = 0.0
    @State private var contentHeight:CGFloat = kMinimizedStateContentHeight
    @State private var partialContentHeightMax:CGFloat = kMinimizedStateContentHeight
    
    var body: some View {
        
        GeometryReader {proxy in
            let size = proxy.size
            
            ZStack(alignment: .bottom) {
                
                backgroundColor
                    .opacity(dragState.backgroundOpacity)
                    .onTapGesture {
                        //dismiss on tap of the out of the partially visible content
                    }
                    .preference(key: ViewSizeKey.self, value: size)
                    
                let height = proxy.size.height
                
                
                VStack {
                    Spacer() //push content to the bottom
                    
                    VStack {
//                        if case .top = dragState {
                            HStack{
                                Spacer()
                                Button(action: {
                                    print("close button tapped")
                                    print("height: \(height)")
                                }, label: {
                                    Image(systemName: "x.square.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:32, height:32)
                                        .padding(4)
                                    
                                })
                                .disabled(dragState != .top)
                                .opacity(dragState.dependentOpacity)
                            }
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
//                        }
                        
//                        if dragState != .bottom {
                            textsView
                                .opacity(dragState.dependentOpacity)
                                .scaleEffect(.init(width:1.0, height:dragState.dependentVerticalScale),
                                             anchor: .top)
//                        }
                        //player bugtons
                        buttonControls
                        //slider
                        ExpandableSlider(value: $playerProgress, in: 0...1, overlay: {
                            HStack {
                                Text("Player Overlay text")
                                Spacer()
                            }
                            .padding(.horizontal)
                        })
                    }
                    .background(Color.white)
                    .frame(minHeight: kMinimizedStateContentHeight)
                    .frame(height: contentHeight)
                    .background(Color.white)
                }
                .onAppear {
                    maxContentHeight = height
                }
                
            }
            
            .gesture(DragGesture()
                .onChanged({ dragValue in
                let pos = dragValue.startLocation.y
                let verticalTranslation = dragValue.translation.height
                
                print("start: \(pos), transl: \(verticalTranslation)")
            }))
                
        }
        .ignoresSafeArea(edges: [.bottom, .top])
        .onAppear(perform: {
            //testAnimation()
            dragState = .top
        })
        .onPreferenceChange(ViewSizeKey.self, perform: {size in
            partialContentHeightMax = size.height * 0.66
        })
        .onChange(of: dragState) { oldValue, newValue in
            contentHeight = max(kMinimizedStateContentHeight, min(partialContentHeightMax, newValue.dependentVerticalScale * partialContentHeightMax))
        }
        
        
    }
    
    private func testAnimation() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            withAnimation(.linear(duration: 1.0)){
                dragState = .fraction(0.5)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                withAnimation{
                    dragState = .top
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    withAnimation{
                        dragState = .bottom
                    }
                })
            })
        })
    }
    
    @ViewBuilder private var textsView: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .padding()
            
            Text(details)
                .padding()
            
        }
    }
    
    @ViewBuilder private var buttonControls: some View {
        HStack(spacing: 16) {
            Button(action: {
                //rewind
                print("rewind tapped")
            }, label: {
                Image(systemName: "backward")
            })
            .tint(.green)
            .buttonStyle(.roundedBorderButton)
            
            
            Button(action:{
                //play
                print("play tapped")
            }, label : {
                Image(systemName:"play")
            })
            .buttonStyle(.roundedBorderButton)
            .scaleEffect(1.2)
            
            Button(action: {
                //fast forward
                print("ff tapped")
            }, label: {
                Image(systemName: "forward")
            })
            .buttonStyle(.roundedBorderButton)
        }
        
        
    }
}

#Preview {
    @Previewable @State var progress:CGFloat = 0.4
    PlayerContainerView(title:"Audio Title", details: "Some Lorem Ipsum text", playerProgress: $progress)
}
