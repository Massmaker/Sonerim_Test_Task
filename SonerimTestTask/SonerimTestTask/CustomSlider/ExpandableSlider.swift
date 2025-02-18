//
//  ExpandableSlider.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 18.02.2025.
//

import SwiftUI

/**
 A slider that grows in height while is draging, accepts external view for overlay e.g. some text representation of the target value updates
  - Note: The implementation taken from the [Kavsoft](https://www.youtube.com/watch?v=ZOJVGQwX4wg)
 
 Example:
 
 ````
 
    #Preview {
        @Previewable @State var sliderValue:CGFloat = 20
        NavigationStack {
            VStack {
                ExpandableSlider(value: $sliderValue, in: 0...100, overlay: {
                    HStack {
                        Image(systemName:"speaker.wave.3.fill", variableValue: sliderValue / 100)
                        Spacer()
                        Text("Overlay text").font(.callout)
                    }
                    .padding(.horizontal)
                })
                .padding()
                .border(Color.accentColor, width: 1)
                .padding(16)
            }
            .navigationTitle("Custom Slider Preview")
        }
    }
 ````
*/
struct ExpandableSlider<Overlay: View> {
    
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat>
    var config: Configuration
    var overlay: Overlay
    @State private var lastStoredValue: CGFloat
    @GestureState private var isActive: Bool = false
    
    struct Configuration {
        
        var cornerRadius:CGFloat = 16
        var extraHeight:CGFloat = 26
        
        var tintConfiguration:TintConfiguration = TintConfiguration(activeTint: Color.primary, inactiveTint: Color.primary.opacity(0.06))
        var overlayConfig:TintConfiguration = .init(activeTint: Color.white, inactiveTint: Color.secondary)
        
        
        struct TintConfiguration {
            var activeTint:Color
            var inactiveTint:Color
        }
    }
    
    
    init(value: Binding<CGFloat>,
         in range: ClosedRange<CGFloat>,
         config: Configuration = .init(),
         @ViewBuilder overlay: @escaping () -> Overlay) {
        self._value = value
        self.range = range
        self.config = config
        self.overlay = overlay()
        self.lastStoredValue = value.wrappedValue
    }
}



extension ExpandableSlider:View {
    var body: some View {
        GeometryReader {
            let size = $0.size
            let sizeWidth = size.width
            let width = (value / range.upperBound) * sizeWidth
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(config.tintConfiguration.inactiveTint)
                
                Rectangle()
                    .fill(config.tintConfiguration.activeTint)
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: width)
                    }
                
                // the supplied overlay
                ZStack(alignment: .leading, content: {
                    overlay
                        .foregroundStyle(config.overlayConfig.inactiveTint)
                    
                    overlay.foregroundStyle(config.overlayConfig.activeTint)
                        .mask(alignment: .leading) {
                            Rectangle()
                                .frame(width:width)
                        }
                })
                .compositingGroup()
                //different revealing and hiding animation for overlay view
                .animation(.easeInOut(duration: 0.25).delay(isActive ? 0.12 : 0).speed(isActive ? 1 : 2), body: {
                    $0.opacity(isActive ? 1.0 : 0.0)
                })
            }
            .contentShape(.rect)
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isActive, body: {value, inoutState, inoutTransaction in
                        inoutState = true
                    })
                    .onChanged({ value in
                        let progress = (value.translation.width / sizeWidth) * range.upperBound + lastStoredValue
                        self.value = max(range.lowerBound, min(range.upperBound, progress))
                    })
                    .onEnded({ _ in
                        lastStoredValue = self.value
                    })
            )
            
        }
        .frame(height:20 + config.extraHeight)
        .mask {
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .frame(height: 20 + (isActive ? config.extraHeight : 0))
        }
        .animation(.snappy(duration: (isActive ? 0.1 : 0.3)), value: isActive)
    }
}

#Preview {
    @Previewable @State var volumeLevel:CGFloat = 20
    NavigationStack {
        VStack {
            ExpandableSlider(value: $volumeLevel, in: 0...100, overlay: {
                HStack {
                    Image(systemName:"speaker.wave.3.fill", variableValue: volumeLevel / 100)
                    Spacer()
                    Text(String(format:"%.1f", volumeLevel) + "%")
                        .font(.callout)
                }
                .padding(.horizontal)
            })
            .padding()
            .border(Color.accentColor, width: 1)
            .padding(16)
        }
        .navigationTitle("Custom Slider Preview")
    }
}
