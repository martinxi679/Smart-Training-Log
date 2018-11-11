//
//  CommentModel.swift
//  Smart Training Log
//
//  Created by Alice Lew on 11/11/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import Foundation

protocol CommentModel {
    
    var id: String? {get set}
    var athleteID: String? {get set}
    var trainerID: String? {get set}
    var date: Date? {get set}
    var content: String? {get set}
    
}

extension CommentModel {
    mutating func update(with model: CommentModel) {
        id = model.id
        athleteID = model.athleteID ?? athleteID
        trainerID = model.trainerID ?? trainerID
        date = model.date ?? date
        content = model.content ?? content
    }
}
