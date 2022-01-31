//
//  NSTouchPhase+Description.swift
//  GibTV
//
//  Created by Eric Rabil on 1/30/22.
//

import Foundation
import AppKit

extension NSTouch.Phase {
    var description: String {
        switch self {
        case .any:
            return "any"
        case .began:
            return "began"
        case .cancelled:
            return "cancelled"
        case .ended:
            return "ended"
        case .moved:
            return "moved"
        case .stationary:
            return "stationary"
        case .touching:
            return "touching"
        default:
            return "NSTouchPhase(rawValue: \(rawValue))"
        }
    }
}
