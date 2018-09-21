//
//  RoundRectButton.swift
//  Smart Training Log
//

import UIKit

class RoundRectButton: UIButton {
    
    @IBInspectable var defaultOutlineColor: UIColor = .clear
    @IBInspectable var defaultBackgroundColor: UIColor = .white
    @IBInspectable var defaultOutlineWidth: CGFloat = 0.0
    
    @IBInspectable var disabledOutlineColor: UIColor = .clear
    @IBInspectable var disabledBackgroundColor: UIColor = .white
    @IBInspectable var disabledOutlineWidth: CGFloat = 0.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        if isEnabled {
            self.layer.borderWidth = self.defaultOutlineWidth
            UIView.animate(withDuration: 0.15) {
                self.layer.borderColor = self.defaultOutlineColor.cgColor
                self.backgroundColor = self.defaultBackgroundColor
            }
        } else {
            self.layer.borderWidth = self.disabledOutlineWidth
            UIView.animate(withDuration: 0.15) {
                self.layer.borderColor = self.disabledOutlineColor.cgColor
                self.backgroundColor = self.disabledBackgroundColor
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            setNeedsLayout()
        }
    }
}
