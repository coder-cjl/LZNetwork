import Foundation
import UIKit

public class LZCache {
    public static let `default` = LZCache()
    
    public var urlCache: URLCache?
    public var cachePolicy: NSURLRequest.CachePolicy = .returnCacheDataDontLoad
    
    init() {
        defaultConfig()
        addObserver()
    }
    
    func defaultConfig() {
        let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheURL = cacheDirectoryURL.appendingPathComponent("LZNetworkCache")
        print(cacheURL.absoluteString)
        
        urlCache = URLCache(
            memoryCapacity: 4 * 1024 * 1024,
            diskCapacity: 20 * 1024 * 1024,
            directory: cacheURL
        )
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.cleanCacheIfNeed()
        }
    }
    
   public func cleanCacheIfNeed() {
        let cache = URLCache.shared
        let maxCacheSize = 20 * 1024 * 1024
        let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60
        
        if cache.currentDiskUsage > maxCacheSize {
            cache.removeCachedResponses(since: Date(timeIntervalSinceNow: -maxCacheAge))
        }
    }
}
