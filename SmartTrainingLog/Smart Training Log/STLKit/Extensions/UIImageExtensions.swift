//
//  UIImageExtensions.swift
//  Smart Training Log
//

import UIKit

extension UIImage {

    func compressed(to bytes: Int) -> Data? {
        guard var data = UIImagePNGRepresentation(self) else { return nil }
        while data.count > bytes {
            let compressionRatio: CGFloat = 0.9
            if let newData = UIImageJPEGRepresentation(self, compressionRatio) {
                data = newData
            } else {
                return nil
            }
        }
        return data
    }

}
