//
//  UIImageExtensions.swift
//  Smart Training Log
//

import UIKit

extension UIImage {

    func compressed(to bytes: Int) -> UIImage? {
        guard var data = UIImagePNGRepresentation(self) else { return nil }
        if data.count > bytes {
            let compressionRatio: CGFloat = CGFloat(bytes / data.count)
            if let newBytes = UIImageJPEGRepresentation(self, compressionRatio) {
                return UIImage(data: newBytes)
            } else {
                return nil
            }
        } else {
            return self
        }
    }

}
