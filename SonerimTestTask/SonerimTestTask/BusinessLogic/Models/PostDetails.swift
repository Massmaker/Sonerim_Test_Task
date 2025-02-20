//
//  PostDetails.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 20.02.2025.
//

import UIKit
import Observation

final class PostDetails:ObservableObject {
    
    let title:String
    private(set) var image:UIImage
    let detailsContainer:PrintableSortedValuesContainer
    
    init(title: String, image: UIImage, detailsContainer: PrintableSortedValuesContainer) {
        self.title = title
        self.image = image
        self.detailsContainer = detailsContainer
    }
}
