//
//  UIViewExtensions.swift
//  Smart Training Log
//

import UIKit

extension UIView {

    /// Recursivly goes through sub views and attempts to find the first
    /// responder, if there is one
    func getFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        } else {
            for view in subviews {
                if let responder = view.getFirstResponder() {
                    return responder
                }
            }
            return nil
        }
    }

}
