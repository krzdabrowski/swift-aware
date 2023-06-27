//
//  DispatchTimeInterval+TimeInterval.swift
//  Aware
//
//  Created by Michal Cichecki on 2023-06-27.
//  Copyright © 2023 Joshua Peek. All rights reserved.
//

import Foundation

extension DispatchTimeInterval {
    public var timeInterval: TimeInterval {
        switch self {
        case .seconds(let value):
            return Double(value)
        case .milliseconds(let value):
            return Double(value) / 1e3
        case .microseconds(let value):
            return Double(value) / 1e6
        case .nanoseconds(let value):
            return Double(value) / 1e9
        case .never:
            return .infinity
        @unknown default:
            assertionFailure("Unknown case not handled: \(self)")
            return 0
        }
    }
}
