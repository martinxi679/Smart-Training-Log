//
//  DateExtensions.swift
//  Smart Training Log
//

import Foundation

extension Date {
    func isWithinSeconds(_ seconds: Int) -> Bool {
        let epoch = self.timeIntervalSince1970
        let future = self.addingTimeInterval(Double(seconds)).timeIntervalSince1970

        return self.timeIntervalSinceNow > epoch && self.timeIntervalSinceNow <= future
    }
}
