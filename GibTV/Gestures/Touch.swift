//
//  Touch.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import AppKit

extension NSTouch {
    var index: Int {
        Int(value(forKey: "index") as! CLongLong)
    }
}

struct Touch: Identifiable {
    /// `Identifiable` -> `id` is required for `ForEach` (see below).
    let id: Int
    /// Normalized touch X position on a device (`0.0` - `1.0`).
    let normalizedX: CGFloat
    /// Normalized touch Y position on a device (`0.0` - `1.0`).
    let normalizedY: CGFloat

    init(_ nsTouch: NSTouch) {
        self.normalizedX = nsTouch.normalizedPosition.x
        /// `NSTouch.normalizedPosition.y` is flipped -> 0.0 means bottom. But the `Touch` structure is meant to be used with the SwiftUI, so flip it.
        self.normalizedY = 1.0 - nsTouch.normalizedPosition.y
        self.id = nsTouch.index
    }
}
