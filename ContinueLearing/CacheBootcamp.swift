//
//  CacheBootcamp.swift
//  ContinueLearing
//
//  Created by TOTI SABZ on 3/8/25.
//

import SwiftUI

class CacheManager{
    
    static let instance = CacheManager()
    private init(){}
    
    var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100mb maybe
        return cache
    }()
    
    func add(image: UIImage, name: String){
        imageCache.setObject(image, forKey: name as NSString)
    }
    
    func remove(name: String){
        imageCache.removeObject(forKey: name as NSString)
    }
    
    func get(name: String) -> UIImage?{
        let image = imageCache.object(forKey: name as NSString)
        return image
    }
}

class CacheViewModel: ObservableObject {
    @Published var starterImage: UIImage? = nil
    @Published var cachedImage: UIImage? = nil
    let imageName: String = "steve-jobs"
    
    let cacheManager: CacheManager = CacheManager.instance
    
    init() {
        getImageFromAssets()
    }
    
    
    func getImageFromAssets() {
        starterImage = UIImage(named: imageName)
    }
    
    func getImageFromCache() {
        let fetchedImage = cacheManager.get(name: imageName)
        cachedImage = fetchedImage
    }
    
    func saveImageToCache() {
        guard let image = starterImage else { return }
        cacheManager.add(image: image, name: imageName)
    }
    
    func removeImageFromCache() {
        cacheManager.remove(name: imageName)
    }
}

struct CacheBootcamp: View {
    
    @StateObject var vm: CacheViewModel = CacheViewModel()
    
    var body: some View {
        VStack{
            if let image = vm.starterImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            Button("Save to cache") {
                vm.saveImageToCache()
            }
            
            Button("Delete from cache") {
                vm.removeImageFromCache()
            }
            
            Button("Get from cache") {
                vm.getImageFromCache()
            }
            
            Spacer().frame(height: 40)

            if let image = vm.cachedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }else{
                Text("No cached image found")
            }

        }
    }
}

#Preview {
    CacheBootcamp()
}
