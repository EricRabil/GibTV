//
//  CGEvent+Interpretation.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import CoreGraphics

extension CGEventType {
    var isSelectEvent: Bool {
        isSelectPressedEvent || isSelectReleasedEvent
    }
    
    var isSelectPressedEvent: Bool {
        self == .leftMouseDown
    }
    
    var isSelectReleasedEvent: Bool {
        self == .leftMouseUp
    }
    
    var meansWeShouldReenableTap: Bool {
        self == .tapDisabledByUserInput
    }
    
    var isInterestingTouchEvent: Bool {
        rawValue == 29
    }
}
