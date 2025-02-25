//
//  PostDummies.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation
import UIKit //for UIImage

extension PostInfo {
    static var dummies:[PostInfo] = [
        PostInfo(title: "2025_02_01_Drum Runners_0286-Enhanced-NR",
                 image: UIImage(named: "DummyImage"),
                 mediaURLString: "https://live.staticflickr.com/65535/54334697787_a48bb4a6e7_m.jpg"),
        PostInfo(title: "2025_02_01_Drum Runners_0691-Enhanced-NR",
                 image: nil,
                 mediaURLString: "https://live.staticflickr.com/65535/54335859858_160435476a_m.jpg"),
        PostInfo(title: "2025_02_01_Drum Runners_0723-Enhanced-NR",
                 image: nil,
                 mediaURLString: "https://live.staticflickr.com/65535/54335848879_bb14c64940_m.jpg")
    ]
}

extension PostItem {
    static var dummies:[PostItem] = [dummy1]
    
    static var dummy1:PostItem =
    PostItem(title: "2025_02_01_Drum Runners_0734-Enhanced-NR",
             link: "https://www.flickr.com/photos/44931404@N04/54335630356/",
             media: Media(m:"https://live.staticflickr.com/65535/54335630356_ed0d540d24_m.jpg"),
             dateTaken: Date(timeIntervalSince1970: 1_000_000),
             description: " <p><a href=\"https://www.flickr.com/people/44931404@N04/\">tbottom</a> posted a photo:</p> <p><a href=\"https://www.flickr.com/photos/44931404@N04/54335630356/\" title=\"2025_02_01_Drum Runners_0734-Enhanced-NR\"><img src=\"https://live.staticflickr.com/65535/54335630356_ed0d540d24_m.jpg\" width=\"240\" height=\"179\" alt=\"2025_02_01_Drum Runners_0734-Enhanced-NR\" /></a></p> <p>2025 02 01 Drum Runners Games #2</p>",
             published: Date().addingTimeInterval(-72000),
             author: "nobody@flickr.com (\"tbottom\")",
             authorId: "44931404@N04",
             tags: "drumrunners stjohnscountyhorsecouncil stjohnscountyfairgrounds staugustine elkton florida barrelracing barrelracers horses sports terrybottom")
}


