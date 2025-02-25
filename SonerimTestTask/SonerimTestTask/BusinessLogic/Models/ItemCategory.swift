//
//  ItemCategory.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation

///Data object used as non-empty string container
struct ItemCategory: Hashable {
    
    let name:String
    
    init?(name: String) {
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
    }
}
