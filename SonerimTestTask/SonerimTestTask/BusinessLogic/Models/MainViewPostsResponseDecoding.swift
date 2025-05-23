//
//  Post.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601

    return decoder
}

//MARK: - Decodaable Response
struct CategoryItemsResponse: Decodable {
    let title: String
    let link: String
    let description: String
    let modified: Date
    let generator: String
    let items: [PostItem]

    enum CodingKeys: String, CodingKey {
        case title
        case link
        case description
        case modified
        case generator
        case items
    }
}

struct PostItem: Decodable, Hashable {
    let title: String
    let link: String
    let media: Media
    let dateTaken: Date
    let `description`: String
    let published: Date
    let author: String
    let authorId: String
    let tags: String
    
}

struct Media: Decodable, Hashable {
    let m: String
}

//MARK: - Extensions

protocol PrintableSortedValuesContainer {
    var printableSortedValues: [(String,String)] {get}
}

protocol MediaURLsContainer {
    var mediaURLString: String {get}
}

extension PostItem:PrintableSortedValuesContainer {
    var printableSortedValues: [(String,String)] {
        let mirror = Mirror(reflecting: self)
        
        var result:[(String,String)] = []
        
        let unwantedVKeys = Set(["title", "description", "media"])
        
        let filteredChildren = mirror.children.filter({
            guard let propName = $0.0 else { return false }
            return !unwantedVKeys.contains(propName)
        })
        
        for (property, value) in filteredChildren {

            guard let propertyName = property else {
                continue
            }
            
            if propertyName == "tags", let string = value as? String {
                let tagsString = string
                    .components(separatedBy: CharacterSet.whitespacesAndNewlines)//split to separate substrings
                    .map({"#\($0)"})// prefix each substring with the "#" sign
                    .joined(separator: " ")// resutn single string of substrings separated by whitespaces
                
                result.append((propertyName, tagsString))
                continue
            }
            
            
            
            result.append((propertyName ,"\(value)"))
        }
        
        return result
    }
}

extension PostItem: MediaURLsContainer {
    var mediaURLString: String {
        
        guard media.m.hasSuffix("m.jpg"), let range = media.m.range(of: "m.jpg") else {
            return media.m
        }
        
        let bigImageURL = media.m.replacingCharacters(in: range, with: "b.jpg")
        
        return bigImageURL
    }
}

extension PostItem {
    /// - Returns: self.media.m
    var postId:String {
        media.m
    }
}






/**
 Example of the resopnse handled by the app:
 Request:
 (search by: "Horses")
 `https://api.flickr.com/services/feeds/photos_public.gne?format=json&tags=horses&nojsoncallback=1`
 
 ````
 {
         "title": "Recent Uploads tagged horses",
         "link": "https:\/\/www.flickr.com\/photos\/tags\/horses\/",
         "description": "",
         "modified": "2025-02-18T14:30:11Z",
         "generator": "https:\/\/www.flickr.com",
         "items": [
        {
             "title": "2025_02_01_Drum Runners_0734-Enhanced-NR",
             "link": "https:\/\/www.flickr.com\/photos\/44931404@N04\/54335630356\/",
             "media": {"m":"https:\/\/live.staticflickr.com\/65535\/54335630356_ed0d540d24_m.jpg"},
             "date_taken": "2025-02-01T02:50:38-08:00",
             "description": " <p><a href=\"https:\/\/www.flickr.com\/people\/44931404@N04\/\">tbottom<\/a> posted a photo:<\/p> <p><a href=\"https:\/\/www.flickr.com\/photos\/44931404@N04\/54335630356\/\" title=\"2025_02_01_Drum Runners_0734-Enhanced-NR\"><img src=\"https:\/\/live.staticflickr.com\/65535\/54335630356_ed0d540d24_m.jpg\" width=\"240\" height=\"179\" alt=\"2025_02_01_Drum Runners_0734-Enhanced-NR\" \/><\/a><\/p> <p>2025 02 01 Drum Runners Games #2<\/p> ",
             "published": "2025-02-18T14:30:11Z",
             "author": "nobody@flickr.com (\"tbottom\")",
             "author_id": "44931404@N04",
             "tags": "drumrunners stjohnscountyhorsecouncil stjohnscountyfairgrounds staugustine elkton florida barrelracing barrelracers horses sports terrybottom"
        },
        {
             "title": "2025_02_01_Drum Runners_0723-Enhanced-NR",
             "link": "https:\/\/www.flickr.com\/photos\/44931404@N04\/54335848879\/",
             "media": {"m":"https:\/\/live.staticflickr.com\/65535\/54335848879_bb14c64940_m.jpg"},
             "date_taken": "2025-02-01T02:50:00-08:00",
             "description": " <p><a href=\"https:\/\/www.flickr.com\/people\/44931404@N04\/\">tbottom<\/a> posted a photo:<\/p> <p><a href=\"https:\/\/www.flickr.com\/photos\/44931404@N04\/54335848879\/\" title=\"2025_02_01_Drum Runners_0723-Enhanced-NR\"><img src=\"https:\/\/live.staticflickr.com\/65535\/54335848879_bb14c64940_m.jpg\" width=\"193\" height=\"240\" alt=\"2025_02_01_Drum Runners_0723-Enhanced-NR\" \/><\/a><\/p> <p>2025 02 01 Drum Runners Games #2<\/p> ",
             "published": "2025-02-18T14:30:06Z",
             "author": "nobody@flickr.com (\"tbottom\")",
             "author_id": "44931404@N04",
             "tags": "drumrunners stjohnscountyhorsecouncil stjohnscountyfairgrounds staugustine elkton florida barrelracing barrelracers horses sports terrybottom"
        },
        {
             "title": "2025_02_01_Drum Runners_0939-Enhanced-NR",
             "link": "https:\/\/www.flickr.com\/photos\/44931404@N04\/54336062320\/",
             "media": {"m":"https:\/\/live.staticflickr.com\/65535\/54336062320_a1b5e9f7a2_m.jpg"},
             "date_taken": "2025-02-01T03:11:03-08:00",
             "description": " <p><a href=\"https:\/\/www.flickr.com\/people\/44931404@N04\/\">tbottom<\/a> posted a photo:<\/p> <p><a href=\"https:\/\/www.flickr.com\/photos\/44931404@N04\/54336062320\/\" title=\"2025_02_01_Drum Runners_0939-Enhanced-NR\"><img src=\"https:\/\/live.staticflickr.com\/65535\/54336062320_a1b5e9f7a2_m.jpg\" width=\"240\" height=\"203\" alt=\"2025_02_01_Drum Runners_0939-Enhanced-NR\" \/><\/a><\/p> <p>2025 02 01 Drum Runners Games #2<\/p> ",
             "published": "2025-02-18T14:35:11Z",
             "author": "nobody@flickr.com (\"tbottom\")",
             "author_id": "44931404@N04",
             "tags": "drumrunners stjohnscountyhorsecouncil stjohnscountyfairgrounds staugustine elkton florida barrelracing barrelracers horses sports terrybottom"
        }
        ]
 }
 ````
 */

