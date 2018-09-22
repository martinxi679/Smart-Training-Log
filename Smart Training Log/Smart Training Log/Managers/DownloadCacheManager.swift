//
//  DownloadCacheManager.swift
//  Smart Training Log
//

import Foundation

class DownloadCacheManager {

    private static let MEGA_BYTE_SIZE = 1024 * 1024

    private static let diskSize = 40 * DownloadCacheManager.MEGA_BYTE_SIZE
    private static let memorySize = 10 * DownloadCacheManager.MEGA_BYTE_SIZE
    private static let cacheLocation = "SmartTrainingLogResourceCache"

    public let cache: URLCache

    init() {

        cache = URLCache(memoryCapacity: DownloadCacheManager.memorySize, diskCapacity: DownloadCacheManager.diskSize, diskPath: DownloadCacheManager.cacheLocation)

        let session = try? Container.resolve(URLSession.self)

        let config = session?.configuration ?? URLSessionConfiguration.default
        config.urlCache = cache
    }

}
