//
//  TVRXDevice+Bindings.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import TVRemoteCore
import SwiftUI

// MARK: - Bindings
extension TVRXDevice {
    var binding: Binding<TVRXDevice> {
        GibTVState.shared.binding(forDictionary: \.devicesByID, atKey: id, defaultValue: TVRXDevice())
    }
    
    var binding_supportedButtons: Binding<[TVRCButton]> {
        GibTVState.shared.binding(forDictionary: \.deviceButtons, atKey: id, defaultValue: [])
    }
    
    var binding_editingContext: Binding<TVRCKeyboardAttributes?> {
        GibTVState.shared.binding(forDictionary: \.editingContexts, atKey: self)
    }
    
}

/// Adds an `Identifiable` conformance so that `TVRXDevice` can be used in a `SwiftUI.ForEach`
extension TVRXDevice: Identifiable {}
