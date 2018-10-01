//
//  DummyTreatment.swift
//  Smart Training Log
//
//  Created by Alice Lew on 9/30/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class DummyTreatment {
    var title: String?
    var content: String?
    var date: Date
    var uid: String?
    // maybe uid: String ?
    // also include trainer: User ?
    
    init(with uid: String, title: String, content: String) {
        self.title = title;
        self.uid = uid;
        self.date = Date();
        self.content = content;
    }
    var id: String {
        return uid!
    }
}
