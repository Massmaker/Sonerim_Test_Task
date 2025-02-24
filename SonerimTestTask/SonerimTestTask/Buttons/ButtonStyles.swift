//
//  ButtonStyles.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 21.02.2025.
//

import SwiftUI

struct Custom {}

extension Custom {
    struct RoundedBorderButtonStyle:ButtonStyle {
        let borderColor:Color
        let borderWidth:CGFloat
        
        func makeBody(configuration: Configuration) -> some View {
            ButtonContent(label: configuration.label, borderWidth: borderWidth, color: borderColor)
                .opacity(configuration.isPressed ? 0.7 : 1.0)
            
        }
    }
}


extension Custom {
    struct ButtonContent<Label:View> : View {
        let label:Label
        let borderWidth:CGFloat
        let color:Color
        
        var body: some View {
            
            label
                .padding(16)
                .clipShape(Circle())
                .background(content: {
                    Circle()
                        .stroke(color, lineWidth: borderWidth)
                        
                })
                
        }
    }
}

extension ButtonStyle where Self == Custom.RoundedBorderButtonStyle {
    //Use this if you don't need customization
    static var roundedBorderButton:Self {
        roundedBorderButton(borderColor: .primary, borderWidth: 1)
    }
    
    //Use this if you need some customization
    static func roundedBorderButton(borderColor bColor:Color, borderWidth bWidth:CGFloat) -> Self {
        Self(borderColor: bColor, borderWidth: bWidth)
    }
}


//MARK: - Preview
struct ButtonStypePreview:View {
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                //rewind
                print("rewind tapped")
            }, label: {
                Image(systemName: "backward")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            })
            .frame(width: 60, height: 60)
            .buttonStyle(.roundedBorderButton)
            .foregroundStyle(Color.mint)
            
            
            
            
            Button(action:{
                //play
                print("play tapped")
            }, label : {
                Image(systemName:"play")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 40)
            })
            .buttonStyle(.roundedBorderButton)
            .scaleEffect(2)
            
            Button(action: {
                //fast forward
                print("ff tapped")
            }, label: {
                Image(systemName: "forward")
            })
            .buttonStyle(.roundedBorderButton(borderColor: Color.red, borderWidth: 4))
            .foregroundStyle(Color.purple)
            
        }
    }
}
#Preview {
    ButtonStypePreview()
}
