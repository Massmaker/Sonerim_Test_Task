//
//  PostInfo.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import UIKit

import Observation

@Observable
class PostInfo {
    let title:String
    var image:UIImage?
    private var mediaURLString:String
    
    init(title: String, image: UIImage? = nil, mediaURLString: String) {
        self.title = title
        self.image = image
        self.mediaURLString = mediaURLString
    }
}

extension PostInfo:Identifiable {
    var id:String {
        get{
            mediaURLString
        }
        set {
            mediaURLString = newValue
        }
    }
}
