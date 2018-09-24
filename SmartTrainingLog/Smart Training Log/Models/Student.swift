//
//  Student.swift
//  Smart Training Log
//
//  Created by Alice Lew on 9/22/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class Student {
    var name: String
    var year: Int
    var sport: Sport
    var user: User
    
    init(with user: User, name: String, year: Int, sport: Sport) {
        self.name = name;
        self.user = user;
        self.year = year;
        self.sport = sport;
    }
    
    var email: String? {
        return user.email
    }
    
    var id: String {
        return user.uid
    }
}
