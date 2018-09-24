//
//  UnderlineTextField.swift
//  Smart Training Log
//

import UIKit

class UnderlineTextField: UITextField {
    
    private var underlineView: UIView
    
    override init(frame: CGRect) {
        underlineView = UIView()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        underlineView = UIView()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        underlineView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = Palette.accentGrey
        addSubview(underlineView)
        
        underlineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        underlineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        underlineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        underlineView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }
    
}
