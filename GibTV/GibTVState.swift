//
//  GibTVState.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import SwiftUI
import TVRemoteCore

class GibTVState: ObservableObject {
    static let shared = GibTVState()
    
    @Published
    var devicesByID: [String: TVRXDevice] = [:] {
        didSet {
            devices = Array(devicesByID.values)
            deviceButtons = devicesByID.mapValues { Array($0.supportedButtons()) }
        }
    }
    
    @Published
    var deviceButtons: [String: [TVRCButton]] = [:]
    
    @Published
    var editingContexts: [TVRXDevice: TVRCKeyboardAttributes] = [:]
    
    @Published
    var activeKeyboardControllers: [TVRXDevice: TVRXKeyboardController] = [:]
    
    @Published
    var activeEditingTexts: [TVRXDevice: String] = [:]
    
    @Published
    private(set) var devices: [TVRXDevice] = []
}
