//
//  PlayerContainerView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 21.02.2025.
//

import SwiftUI

fileprivate let kMinimizedStateContentHeight:CGFloat = 100

fileprivate let verticalThreshold:CGFloat = 16 //at almost top or bottom border of the visible Content make some animations

struct PlayerContainerView: View {
    
    enum DragState:Equatable {
        case bottom
        case fraction(CGFloat)
        case top
        
        var dependentOpacity:CGFloat {
            if case .fraction(let value) = self {
                return value * 0.8
            }
            
            if case .top = self {
                return 1.0
            }
            
            return 0.0
        }
        
        var dependentVerticalScale:CGFloat {
            if case .fraction(let value) = self {
                return value * 0.7
            }
            
            if case .top = self {
                return 1.0
            }
            
            return 0.0
        }
        
        var backgroundOpacity:CGFloat {
            if case .fraction(let value) = self {
                return value * 0.5
            }
            
            if case .top = self {
                return 0.5
            }
            
            return 0.0
        }
    }
    
    //MARK: - Dependencies
    let title:String
    let details:String
    
    @Binding var playerProgress:CGFloat
    var dismissHandler:()->()

    @Environment(PlayerStatus.self) var playerStatus
    
    //MARK: - State
    @State private var backgroundColor:Color = .black
    
    @State private var dragEndState:DragState = .bottom
//    @State private var isFullContentVisible:Bool = false
    @State private var playerViewContentHeight:CGFloat = kMinimizedStateContentHeight
    @State private var viewSize:CGSize = .init(width: 1, height: 1)
    @State private var topStateContentOrigin:CGFloat = 0.0
    @State private var bottomStateContentOrigin:CGFloat = 0.0

    @GestureState private var isDragging:Bool = false
    
    var body: some View {
        
        GeometryReader {proxy in
            let size = proxy.size

            ZStack(alignment: .bottom) {
                
                backgroundColor
                    .opacity(dragEndState.backgroundOpacity)
                    .preference(key: ViewSizeKey.self, value: size)
                
                VStack() {
                    
                            
                    if case .top = dragEndState  {
                        VStack(spacing: 32) {
                         
                                textsView
                                
                                playerButtonsControls
                                    .padding(.bottom, 16)
                                
                            }
                            .padding(.horizontal)
    
                    }
                    else {
                        if case .fraction(let cGFloat) = dragEndState {
                            playerButtonsControls
                                .padding(.bottom, 16)
                        }
                        
                    }
                    
                 
                    VStack {
                        if case .bottom = dragEndState {
                            playerButtonsControls
                        }
                            
                        //slider
                        ExpandableSlider(value: $playerProgress, in: 0...1,config: .init(sliderHeight:10, extraHeight:10),overlay: {
                            HStack {
                                Text("Player Overlay text")
                                Spacer()
                            }
                            .padding(.horizontal)
                        })
                    }
                }
                //.frame(maxWidth: .infinity)
                .frame(height: playerViewContentHeight)
                .background(.thickMaterial)
                .overlay(alignment: .top, content: {
                    dragDownAndCloseControls
                        .opacity(dragEndState.dependentOpacity)
                })
            }
            .ignoresSafeArea(edges: [ .top])
            
        }
        .onAppear(perform: {
            print("On GeometryReader Appear")

        })
        .gesture(DragGesture()
            .updating($isDragging, body: {_, inoutState, _ in
                inoutState = true
            })
            .onChanged({ dragValue in
                print("DRAG onChanged location:\(dragValue.location.y)")
                let startPosY = dragValue.startLocation.y + verticalThreshold
//                        if startPosY < topStateContentOrigin {
//                            print("returning")
//                            return
//                        }
                
                
                
                let verticalTranslation = dragValue.translation.height
                
                let isDownWards:Bool = verticalTranslation > 0

                let absoluteDragTranslationY = abs(verticalTranslation)
                

                if !isDownWards, dragValue.location.y < (topStateContentOrigin + verticalThreshold) {
                    dragEndState = .top
                    return
                }
                
                if isDownWards, dragValue.location.y > (bottomStateContentOrigin - verticalThreshold) {
                    dragEndState = .bottom
                    print("Still Bottom")
                    return
                }
                    
                
                let draggableDistance = bottomStateContentOrigin - topStateContentOrigin
                var currentDragFraction = absoluteDragTranslationY / draggableDistance
                print("DRAG current fraction: \(currentDragFraction)")
                
                
                if currentDragFraction >= 1 {
                    if isDownWards {
                        if dragEndState != .bottom {
                            //withAnimation{
                            playerViewContentHeight = kMinimizedStateContentHeight
                            dragEndState = .bottom
                            //}
                        }
                    }
                    else {
                        if dragEndState != .top {
                            // withAnimation {
                            playerViewContentHeight = self.viewSize.height - topStateContentOrigin
                            dragEndState = .top
                        }
                        //}
                        
                    }
                    return
                }
                else {
                    if isDownWards {
                        currentDragFraction = 1.0 - currentDragFraction
                    }
                    
                    let targetHeight = max(kMinimizedStateContentHeight, (self.viewSize.height - topStateContentOrigin).rounded() * currentDragFraction)
                    print("Drag Targetheight: \(targetHeight)")
                    playerViewContentHeight = targetHeight
                    
                }
                
                if case .bottom = dragEndState, !isDownWards {
                    
                    dragEndState = .fraction(currentDragFraction)
                }
                if case .top = dragEndState, isDownWards {
                    
                    dragEndState = .fraction(currentDragFraction)
                    
                }
                
                if case .fraction = dragEndState {
                    dragEndState = .fraction(currentDragFraction)
                    
                }
                
               
               // print("DragFraction: \(currentDragFraction)")

            })
            .onEnded({ dragValue in
                print("DRAG onEnded")
                if dragValue.location.y <= topStateContentOrigin {
                    withAnimation{
                        dragEndState = .top
//                            isFullContentVisible = true
                    }
                }
                else if dragValue.location.y >= bottomStateContentOrigin {
                    withAnimation {
                        dragEndState = .bottom
//                            isFullContentVisible = false
                    }
                    
                }
                else if case .fraction(let fracValue) = dragEndState {
                    if fracValue > 0.5 {
                        withAnimation(.linear(duration: 0.3)) {
                            dragEndState = .top
//                                isFullContentVisible = true
                        }
                    }
                    if fracValue < 0.5 {
                        withAnimation(.snappy(duration: 0.2)) {
                            dragEndState = .bottom
                        }
                    }
                }
                
            })
        )
        .onPreferenceChange(ViewSizeKey.self, perform: {size in
            let contentHeightMax = (size.height * 0.66).rounded(.down)
            let contentHeightMin = size.height - kMinimizedStateContentHeight

            self.viewSize = size
            self.topStateContentOrigin = size.height - contentHeightMax
            self.bottomStateContentOrigin = contentHeightMin
            
            print("onPreferenceChange Size: \(size.height), partialContentHeightMax: \(contentHeightMax)")
        })
        .onChange(of: topStateContentOrigin) { _, originY in
            print("Player Content Max Height originY: \(originY)")
        }
        .onChange(of: bottomStateContentOrigin, {_ , bottomOrigin in
            print("Player Content Min Height originY: \(bottomOrigin)")
        })
        .onChange(of: dragEndState) { _, newState in
            print("onChange dragEndState: \(newState)")
            switch newState {
            case .top:
                
                break
            case .bottom:
                
                break
            case .fraction:
                break
            }
            
        }
        
    }

    
    @ViewBuilder private var textsView: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .padding(.vertical)
                .lineLimit(3)
            
            Text(details)

        }
    }
    
    @ViewBuilder private var playerButtonsControls: some View {
        @Bindable var status = playerStatus
        PlayerControlsView(isPlaying: $status.isPlayerPlaying, playAction: {}, backwardsTapAction: {}, forwardTapAction: {})
    }
    
    @ViewBuilder private var dragDownAndCloseControls: some View {
        HStack{
            RoundedRectangle(cornerRadius: 3)
                .fill(.secondary)
                .frame(width:100, height:6)
                .padding(.top, 4)
            
        }
        .frame(height: 40, alignment: .top)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing) {
            Button(action: {
                print("close button tapped")
//                isFullContentVisible = false
                
                withAnimation(.linear(duration: 0.2)){
                    playerViewContentHeight = kMinimizedStateContentHeight
                    dragEndState = .bottom
                }
                
            }, label: {
                Image(systemName: "x.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width:30, height:30)
                    .padding(4)
                
            })
            .padding(.horizontal, 8)
            .padding(.top, 6)
            .disabled(dragEndState != .top || isDragging)
        }
        
    }
}

#Preview {
    @Previewable @State var progress:CGFloat = 0.4
    PlayerContainerView(title:"Audio Title Long Name WWWWWWoo",
                        details: "Some Lorem Ipsum text Long text value presented here. Lorem Ipsum text Long text Lorem Ipsum text Long text Lorem Ipsum text Long text. dsfs df   df sdf xfb xcvb dbdfbgh45g fdg tgr",
                        playerProgress: $progress,
                        dismissHandler: {})
}
