//
//  NSCache+Extensions.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 25.02.2025.
//

import Foundation
extension NSCache where KeyType == NSString, ObjectType == ProgressEnumContainer {
    subscript(_ categoryName:String) -> ProgressEnumContainer? {
        get {
            return self.object(forKey: categoryName as NSString)
        }
        set {
            if let new = newValue {
                self.setObject(new, forKey: categoryName as NSString)
            }
            else {
                self.removeObject(forKey: categoryName as NSString)
            }
        }
    }
}
