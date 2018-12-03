//
//  DateExtensions.swift
//  Smart Training Log
//

import Foundation

extension Date {
    func isWithinSeconds(_ seconds: Int) -> Bool {
        let startDate = Date()
        let endDate = self
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: startDate, to: endDate)
        let sec = dateComponents.second!
        return sec <= seconds && sec >= 0
    }
}

extension Date {
    func minutesTill() -> Int {
        let startDate = Date()
        let endDate = self
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.minute], from: startDate, to: endDate)
        let min = dateComponents.minute!
        return min
    }
}
