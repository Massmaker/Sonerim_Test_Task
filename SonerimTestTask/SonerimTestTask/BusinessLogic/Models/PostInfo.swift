//
//  PostInfo.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import UIKit

import Observation

@Observable
class PostInfo:Identifiable {
    let title:String
    var details:String
    var image:UIImage?
    var id:String
    
    init(title: String, details: String, image: UIImage? = nil, id: String) {
        self.title = title
        self.details = details
        self.image = image
        self.id = id
    }
}
