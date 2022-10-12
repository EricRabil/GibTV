//
//  ButtonProperty.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import TVRemoteCore
import SwiftUI

enum ButtonProperty {
    case keyboardShortcut(KeyEquivalent, modifiers: EventModifiers)
    
    static func keyboardShortcut(_ key: KeyEquivalent) -> ButtonProperty {
        .keyboardShortcut(key, modifiers: [])
    }
    
    @_disfavoredOverload static func keyboardShortcut(modifier: EventModifiers, _ key: KeyEquivalent) -> ButtonProperty {
        .keyboardShortcut(key, modifiers: modifier)
    }
}

extension ButtonProperty {
    static let properties: [TVRCButtonType: [ButtonProperty]] = [
        .volumeUp: [.keyboardShortcut(modifier: .command, .upArrow)],
        .playPause: [.keyboardShortcut(.space)],
        .volumeDown: [.keyboardShortcut(modifier: .command, .downArrow)],
        .select: [.keyboardShortcut(.return)],
        .menu: [.keyboardShortcut(.escape)],
        .arrowRight: [.keyboardShortcut(.rightArrow)],
        .arrowDown: [.keyboardShortcut(.downArrow)],
        .arrowUp: [.keyboardShortcut(.upArrow)],
        .arrowLeft: [.keyboardShortcut(.leftArrow)]
    ]
}
