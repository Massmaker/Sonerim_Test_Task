//
//  SonerimTestTaskApp.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 18.02.2025.
//

import SwiftUI

@main
struct SonerimTestTaskApp: App {
    
    @State private var rootModel:RootModel = RootModel()
    
    var body: some Scene {
        WindowGroup {
            RootView(rootModel: rootModel)
        }
    }
}
