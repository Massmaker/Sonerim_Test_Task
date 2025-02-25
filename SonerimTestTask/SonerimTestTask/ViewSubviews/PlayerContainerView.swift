//
//  PlayerContainerView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 21.02.2025.
//

import SwiftUI

fileprivate let kMinimizedStateContentHeight:CGFloat = 100.0

fileprivate let kDragToAnimationThreshold:CGFloat = 100.0

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
                return value * 0.5 + 0.03
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


    @Environment(PlayerStatus.self) var playerStatus
    
    //MARK: - State
    @State private var backgroundColor:Color = .black
    
    @State private var dragEndState:DragState = .bottom
//    @State private var isFullContentVisible:Bool = false
    @State private var playerViewContentHeight:CGFloat = kMinimizedStateContentHeight
    @State private var viewSize:CGSize = .init(width: 1, height: 1)
    @State private var topStateContentOrigin:CGFloat = 0.0
    @State private var bottomStateContentOrigin:CGFloat = 0.0

    @State private var dragStartY:CGFloat = 0.0
    @State private var currentDragOffsetY:CGFloat = 0.0
    
    @GestureState private var isDragging:Bool = false
    
    var body: some View {
        
        GeometryReader {proxy in
            let size = proxy.size

            ZStack(alignment: .bottom) {
                
                backgroundColor
                    .opacity(dragEndState.backgroundOpacity)
                    .preference(key: ViewSizeKey.self, value: size)
                
                
                VStack(spacing: 16) {
                    Spacer()
                    playerButtonsControls
                }
                .frame(maxWidth:.infinity)
                .padding(.bottom, dragEndState == .top ? 48 : 32)
                .frame(height: playerViewContentHeight)
                .background(.thickMaterial)
                .overlay(alignment: .bottom, content: {
                    ExpandableSlider(value: $playerProgress, in: 0...1,config: .init(sliderHeight:10, extraHeight:10),overlay: {
                        HStack {
                            Text("Player Overlay text")
                            Spacer()
                        }
                        .padding(.bottom, 2)
                        .padding(.horizontal)
                    })
                })
                .overlay(alignment: .top, content: {
                    dragDownAndCloseControls
                        .opacity(dragEndState == .top ? 1.0 : (isDragging ? 0.2 : 0.0))
                })
                
                
                if case .top = dragEndState  {
                    VStack( content: {
                        textsView
                            .padding(.horizontal)
                            .padding(.top, 32)
                        Spacer()
                    })
                    .frame(maxHeight:playerViewContentHeight)
                }
            }
            .ignoresSafeArea(edges: [ .top])
            
        }
        .gesture(DragGesture()
            .updating($isDragging, body: {_, inoutState, _ in
                inoutState = true
            })
            .onChanged({ dragValue in
                if dragStartY != dragValue.startLocation.y {
                    dragStartY = dragValue.startLocation.y
                }
                
                currentDragOffsetY = dragValue.translation.height
                
                let verticalTranslation = dragValue.translation.height
                
                let isDownWards:Bool = verticalTranslation > 0

                let absoluteDragTranslationY = abs(verticalTranslation)
                

                if !isDownWards {
                    
                    if case .top = dragEndState, dragValue.startLocation.y > topStateContentOrigin {
                        return
                    }
                    
                    if dragValue.location.y < topStateContentOrigin , dragEndState != .top {
                        dragEndState = .top
                        return
                    }
                }
                
                if isDownWards {
                    
                    if dragValue.location.y > bottomStateContentOrigin {
                        dragEndState = .bottom
                        return
                    }
                }
                    
                
                let draggableDistance = bottomStateContentOrigin - topStateContentOrigin
                var currentDragFraction = absoluteDragTranslationY / draggableDistance
                
                
                if currentDragFraction >= 1 {
                    if isDownWards {
                        if dragEndState != .bottom {
                            shrinkToMinimized()
                        }
                    }
                    else {
                        if dragEndState != .top {
                            playerViewContentHeight = self.viewSize.height - topStateContentOrigin
                            dragEndState = .top
                        }
                    }
                    return
                }
                else {
                    if isDownWards {
                        currentDragFraction = 1.0 - currentDragFraction
                    }
                    
                    let targetHeight = max(kMinimizedStateContentHeight, (self.viewSize.height - topStateContentOrigin).rounded() * currentDragFraction)
                    
                    playerViewContentHeight = targetHeight
                    
                }
                
                if case .bottom = dragEndState, !isDownWards {
                    
                    dragEndState = .fraction(currentDragFraction)
                }
                else if case .top = dragEndState, isDownWards {
                    
                    dragEndState = .fraction(currentDragFraction)
                    
                }
                else if case .fraction = dragEndState {
                    dragEndState = .fraction(currentDragFraction)
                    
                }

            })
            .onEnded({ dragValue in

                if case .fraction = dragEndState {
                    withAnimation{
                        if abs(currentDragOffsetY) > kDragToAnimationThreshold {
                            //proceed with animation to the target edge
                            if currentDragOffsetY < 0 {
                                //was dragging to the top
                                expandToFullSize()
                            }
                            else {
                                //was dragging to the bottom
                                shrinkToMinimized()
                            }
                        }
                        else {
                            //return back to the starting edge
                            if currentDragOffsetY > 0 {
                                //was dragging to the bottom
                                expandToFullSize()
                            }
                            else {
                                //was dragging to the top
                                shrinkToMinimized()
                            }
                        }
                    }
                    currentDragOffsetY = 0.0
                    dragStartY = 0.0
                }
            })
        )
        .onPreferenceChange(ViewSizeKey.self, perform: {size in
            let contentHeightMax = (size.height * 0.66).rounded(.down)
            let contentHeightMin = size.height - kMinimizedStateContentHeight

            self.viewSize = size
            self.topStateContentOrigin = size.height - contentHeightMax
            self.bottomStateContentOrigin = contentHeightMin
            
//            print("onPreferenceChange Size: \(size.height), partialContentHeightMax: \(contentHeightMax)")
        })
//        .onChange(of: topStateContentOrigin) { _, originY in
//            print("Player Content Max Height originY: \(originY)")
//        }
//        .onChange(of: bottomStateContentOrigin, {_ , bottomOrigin in
//            print("Player Content Min Height originY: \(bottomOrigin)")
//        })
//        .onChange(of: dragEndState) { _, newState in
//            print("onChange dragEndState: \(newState)")
//        }
        
    }

    
    @ViewBuilder private var textsView: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .lineLimit(3)
                .padding(.vertical)
                
            Text(details)
        }
        .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder private var playerButtonsControls: some View {
        @Bindable var status = playerStatus
        PlayerControlsView(isPlaying: $status.isPlayerPlaying, playAction: {}, backwardsTapAction: {}, forwardTapAction: {})
    }
    
    @ViewBuilder private var dragDownAndCloseControls: some View {

        HStack{
                RoundedRectangle(cornerRadius: 3)
                    .fill(.secondary)
                    .frame(width:80, height:6)
                    .padding(.top, 6)
        }
        .frame(height: 40, alignment: .top)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing, content: {

            Button(action: {
                print("close button tapped")
                
                withAnimation(.linear(duration: 0.2)){
                    shrinkToMinimized()
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
        })
    }
    
    private func expandToFullSize() {
        playerViewContentHeight = viewSize.height - topStateContentOrigin
        dragEndState = .top
    }
    
    private func shrinkToMinimized() {
        playerViewContentHeight = kMinimizedStateContentHeight
        dragEndState = .bottom
    }
}

#Preview {
    @Previewable @State var status:PlayerStatus = .init()
    @Bindable var pStatus = status
    PlayerContainerView(title:"Audio Title Long Name WWWWWWoo",
                        details: "Some Lorem Ipsum text Long text value presented here. Lorem Ipsum text Long text Lorem Ipsum text Long text Lorem Ipsum text Long text. dsfs df   df sdf xfb xcvb dbdfbgh45g fdg tgr",
                        playerProgress: $pStatus.playerProgress)
}
