//
//  DownloadResourceService.swift
//  Smart Training Log
//

import UIKit

class DownloadResourceService {

    private typealias TaskHandler = (Data?, URLResponse?, Error?) -> Void
    private var urlTaskHandlers: [URL: [TaskHandler]] = [:]

    func downloadResource(from url: URL, handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if var tasks = urlTaskHandlers[url] {
            tasks.append(handler)
        } else {
            urlTaskHandlers[url] = [handler]

            guard let session = try? Container.resolve(URLSession.self) else { return }

            _ = session.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                DispatchQueue.main.async {
                    for taskHandler in self?.urlTaskHandlers[url] ?? [handler] {
                        taskHandler(data, response, error)
                    }
                }
            }).resume()

        }
    }

    func downloadImage(from url: URL, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> UIImage? {
        guard let downloadCacheManager = try? Container.resolve(DownloadCacheManager.self) else { return nil }

        if let data = downloadCacheManager.cache.cachedResponse(for: URLRequest(url: url))?.data {
            return UIImage(data: data)
        } else {
            downloadResource(from: url, handler: handler)
            return nil
        }
    }

}
