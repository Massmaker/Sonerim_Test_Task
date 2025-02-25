//
//  PlayerControlsView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 18.02.2025.
//

import SwiftUI

struct PlayerControlsView: View {
    
    @Binding var isPlaying:Bool
    
    var playAction:() -> ()
    var backwardsTapAction:() -> ()
    var forwardTapAction:() -> ()
    
    
    var body: some View {
        HStack(alignment: .center, spacing:16, content: {
            Button(action: {
                //rewind
                print("rewind tapped")
            }, label: {
                Image(systemName: "backward")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height:24)
            })
            //.frame(maxWidth: 40, maxHeight: 40)
            .buttonStyle(.roundedBorderButton)
            
            
            Button(action:{
                //play
                print("play tapped")
                playAction()
            }, label : {
                Image(systemName:isPlaying ? "pause" : "play")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height:24)
            })
            //.frame(maxWidth: 44, maxHeight: 44)
            .scaleEffect(1.2)
            .buttonStyle(.roundedBorderButton)
            
            
            Button(action: {
                //fast forward
                print("ff tapped")
                forwardTapAction()
            }, label: {
                Image(systemName: "forward")
                    .resizable()
                    .scaledToFit()
                    .frame(width:24, height:24)
            })
            .buttonStyle(.roundedBorderButton)
        })
        
    }
}

#Preview {
    @Previewable @State var isPlaying:Bool = false
    PlayerControlsView(isPlaying: $isPlaying, playAction:{}, backwardsTapAction: {}, forwardTapAction: {} )
}
