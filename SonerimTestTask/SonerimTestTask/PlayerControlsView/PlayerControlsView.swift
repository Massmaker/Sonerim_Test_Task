//
//  PlayerControlsView.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 18.02.2025.
//

import SwiftUI

struct PlayerControlsView: View {
    
    @Binding var isPlaying:Bool
    var bacwardsTapAction:() -> ()
    var backwardsLongpressAction:(Bool) -> ()
    
    var body: some View {
        HStack(alignment: .center, spacing:16, content: {
            
            
            
            Image(systemName: "backward.fill")
                .frame(width:64, height:64)
                .contentShape(Circle())
                .clipShape(Circle())
                .overlay(content:{ Circle().stroke(Color.red, lineWidth: 2)})
                
                
            
                
            Image(systemName: "play.fill")
                .frame(width:64, height:64)
                .contentShape(Circle())
                .clipShape(Circle())
                .overlay(content:{ Circle().stroke(Color.red, lineWidth: 2)})
                .scaleEffect(1.2)
            
            Image(systemName: "forward.fill")
                .frame(width:64, height:64)
                .contentShape(Circle())
                .clipShape(Circle())
                .overlay(content:{ Circle().stroke(Color.red, lineWidth: 2)})
        })
        
    }
}

#Preview {
    PlayerControlsView(isPlaying: .constant(true), bacwardsTapAction: {}, backwardsLongpressAction: {ispressed in })
}
