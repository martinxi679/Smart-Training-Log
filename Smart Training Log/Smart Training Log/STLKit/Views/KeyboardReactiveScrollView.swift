//
//  KeyboardReactiveScrollView.swift
//  Smart Training Log
//

import UIKit

class KeyboardReactiveScrollView: UIScrollView {

    override func awakeFromNib() {

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardDidShow, object: nil, queue: nil) { [weak self] (notification) in
            guard let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
            guard let textField = self?.getFirstResponder() else { return }

            self?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
            self?.scrollRectToVisible(textField.frame, animated: true)
        }

        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: nil) { [weak self] (_) in
            self?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    @objc
    private func dismissKeyboard() {
        self.endEditing(true)
    }

}
