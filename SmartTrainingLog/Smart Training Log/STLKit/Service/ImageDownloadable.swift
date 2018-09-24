//
//  ImageDownloadable.swift
//  Smart Training Log
//

import UIKit


protocol ImageDownloadable: class {}

extension ImageDownloadable {

    func downloadImage(with url: URL, handler: @escaping (UIImage?) -> Void) -> UIImage? {
        guard let downloadService = try? Container.resolve(DownloadResourceService.self) else { return nil }
        let cached = downloadService.downloadImage(from: url, handler: {(data, _, _) in
            if let data = data {
                let image = UIImage(data: data)
                handler(image)
            }
        })

        return cached
    }

    func downloadImage(for imageView: UIImageView, with url: URL, placeHolder: UIImage? = nil, shouldReplace: @escaping (URL, UIImage?) -> Bool = { (_, _) in return true }) {
        if let cachedImage = downloadImage(with: url, handler: { (image) in
            guard let image = image else { return }
            if shouldReplace(url, image) {
                imageView.image = image
            }
        }) {
            imageView.image = cachedImage
        } else if let placeHolder = placeHolder {
            imageView.image = placeHolder
        }
    }
}
