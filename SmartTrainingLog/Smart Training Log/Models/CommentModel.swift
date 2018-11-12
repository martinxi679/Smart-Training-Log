//
//  CommentModel.swift
//  Smart Training Log
//

import Foundation

protocol CommentModel {
    
    var id: String? {get set}
    var trainerID: String? {get set}
    var date: Date? {get set}
    var content: String? {get set}
    
}

extension CommentModel {
    mutating func update(with model: CommentModel) {
        id = model.id
        trainerID = model.trainerID ?? trainerID
        date = model.date ?? date
        content = model.content ?? content
    }
}
