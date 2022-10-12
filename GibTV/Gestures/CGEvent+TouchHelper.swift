//
//  UnifiedTouch.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import AppKit
import TVRemoteCore

private extension NSTouch {
    var tvTouch: TVRCTouchEvent? {
        let timestamp = self.value(forKey: "timestamp") as! Double
        let phase = self.phase
        let index = self.value(forKey: "index") as! CLongLong
        
        var position = self.normalizedPosition
        position.y = 1 - position.y
        
        return TVRCTouchEvent()._init(withTimestamp: timestamp, finger: index, phase: Int64(phase.rawValue), digitizerLocation: position)
    }
}

extension CGEvent {
    struct CGTouchEvent {
        var nsTouch: NSTouch
        var tvTouch: TVRCTouchEvent
        
        init?(nsTouch: NSTouch) {
            self.nsTouch = nsTouch
            guard let tvTouch = nsTouch.tvTouch else {
                return nil
            }
            self.tvTouch = tvTouch
        }
    }
    
    var nsEvent: NSEvent? {
        guard type.isInterestingTouchEvent else {
            return nil
        }
        return NSEvent(cgEvent: self)
    }
    
    func touchEvents() -> [CGTouchEvent]? {
        guard let nsEvent = nsEvent else {
            return nil
        }
        return nsEvent.allTouches().compactMap(CGTouchEvent.init(nsTouch:))
    }
}
