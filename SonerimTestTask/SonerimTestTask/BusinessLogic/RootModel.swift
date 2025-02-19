//
//  RootModel.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 19.02.2025.
//

import Foundation

final class RootModel:ObservableObject {
    lazy var mainViewModel:MainViewViewModel = {
        let vm = Factory.createMainViewViwModel()
        return vm
    }()
}


fileprivate class Factory {
    static func createMainViewViwModel() -> MainViewViewModel {
        
        var categories:[ItemCategory] = []
        
        if let url = Bundle.main.url(forResource: "DefaultCategoriesList", withExtension: "plist") {
            do {
                let data = try Data(contentsOf: url)
                
                let plistDecoder = PropertyListDecoder()
                
                let info = try plistDecoder.decode(BundleCategories.self, from: data)
                
                let validCategories:[ItemCategory] = info.categories
                    .filter({!$0.isEmpty})
                    .compactMap({ItemCategory(name: $0)})
                
                categories = validCategories
            }
            catch {
#if DEBUG
                print("Failed loading of the Default Categories: \(error)")
#endif
            }
        }
        
        let aURLSession = URLSession(configuration: .default)
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let requestsService = URLSessionRequestService(session: aURLSession, decoder: jsonDecoder)
        
        let imageCache = ImageCache(service: requestsService)
        
        
        let mainVM = MainViewViewModel(categories: categories,
                          dataLoader: MainViewDataLoader(service:requestsService),
                          imagesSource: imageCache)
                     
        return mainVM
    }
}


fileprivate struct BundleCategories:Decodable {
    var categories:[String]
}
