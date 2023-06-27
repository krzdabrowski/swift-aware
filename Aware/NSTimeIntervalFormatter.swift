//
//  NSTimeIntervalFormatter.swift
//  Aware
//
//  Created by Joshua Peek on 12/18/15.
//  Copyright © 2015 Joshua Peek. All rights reserved.
//

import Foundation

class NSTimeIntervalFormatter {
    /**
        Formats time interval as a human readable duration string.

        - Parameters:
            - interval: The time interval in seconds.

        - Returns: A `String`.
     */
    func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let intervalInteger = NSInteger(interval)
        let seconds = intervalInteger % 60
        var minutes: Int { (intervalInteger / 60) % 60 }
        var hours: Int { (intervalInteger / 3600) }
        switch interval {
        case 0 ... 60 * 60:
            return String(format: "%0.2d:%0.2d", minutes, seconds)
        default:
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
        }
    }
}
