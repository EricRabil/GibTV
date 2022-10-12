//
//  NSEventModifierFlags+SwiftUI.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import class AppKit.NSEvent
import struct SwiftUI.EventModifiers

extension EventModifiers {
    private static let bindings: [EventModifiers: NSEvent.ModifierFlags] = [
        .command: .command,
        .control: .control,
        .capsLock: .capsLock,
        .option: .option,
        .shift: .shift
    ]
    
    private static let reverseBindings: [NSEvent.ModifierFlags: EventModifiers] = .init(uniqueKeysWithValues: bindings.map {
        ($1, $0)
    })
    
    var nsEventModifierFlags: NSEvent.ModifierFlags {
        Self.bindings.reduce(into: .init(rawValue: 0)) { modifier, pair in
            let (flag, nsFlag) = pair
            if contains(flag) {
                modifier.insert(nsFlag)
            }
        }
    }
    
    init(_ modifiers: NSEvent.ModifierFlags) {
        var tmp = EventModifiers.init(rawValue: 0)
        for (nsFlag, flag) in Self.reverseBindings {
            if modifiers.contains(nsFlag) {
                tmp.insert(flag)
            }
        }
        self = tmp
    }
}

extension NSEvent.ModifierFlags {
    init(_ eventModifiers: SwiftUI.EventModifiers) {
        self = eventModifiers.nsEventModifierFlags
    }
}

extension NSEvent.ModifierFlags: Hashable {
    
}
