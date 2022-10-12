//
//  SwiftUI+Hashable.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import SwiftUI

extension EventModifiers: Hashable {
    
}

extension KeyEquivalent: Hashable {
    public func hash(into hasher: inout Hasher) {
        character.hash(into: &hasher)
    }
    
    public static func == (lhs: KeyEquivalent, rhs: KeyEquivalent) -> Bool {
        lhs.character == rhs.character
    }
}
