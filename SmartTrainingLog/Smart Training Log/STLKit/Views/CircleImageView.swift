//
//  CircleImageView.swift
//  Smart Training Log
//

import UIKit

class CircleImageView: UIImageView {

    override func layoutSubviews() {
        layer.cornerRadius = frame.height/2
        clipsToBounds = true
    }

}
