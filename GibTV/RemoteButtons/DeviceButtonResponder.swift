//
//  DeviceButtonResponder.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import AppKit
import SwiftUI
import TVRemoteCore

class DeviceButtonResponder: NSView {
    static let shared = DeviceButtonResponder()
    
    var pressedButtons: PressedButtonContext!
    var device: TVRXDevice!
    var buttons: [TVRCButton]! {
        didSet {
            guard let buttons = buttons else {
                return
            }
            packed = buttons.reduce(into: .init()) { packed, button in
                switch ButtonProperty.properties[button.buttonType()]?[0] {
                case .keyboardShortcut(let key, modifiers: let modifiers):
                    packed[modifiers, default: [:]][key] = (false, {
                        self.device.send(.init(for: button, eventType: $0 ? .pressed : .released))
                    }, button.buttonType())
                default:
                    return
                }
            }
            packed[.shift, default: [:]][.escape] = (false, { pressed in
                if !pressed {
                    TrackpadProxy.shared.state.enabled = false
                }
            }, nil)
        }
    }
    
    var packed: [EventModifiers: [KeyEquivalent: (Bool, (Bool) -> (), TVRCButtonType?)]] = [:]
    
    override var acceptsFirstResponder: Bool {
        true
    }
    
    func process(_ event: NSEvent, noop: () -> (), pressed: Bool) {
        lazy var modifiers = EventModifiers(event.modifierFlags)
        lazy var key: KeyEquivalent? = {
            guard let characters = event.characters,
                  characters.count == 1 else {
                return nil
            }
            return characters.first.map(KeyEquivalent.init(_:))
        }()
        lazy var character: KeyEquivalent? = event.characters.flatMap {
            guard $0.count == 1 else {
                return nil
            }
            return KeyEquivalent($0[$0.startIndex])
        }
        var storage: (Bool, (Bool) -> (), TVRCButtonType?)? {
            get {
                return key.flatMap {
                    packed[modifiers]?[$0]
                }
            }
            _modify {
                guard packed.keys.contains(modifiers) else {
                    var nothing: (Bool, (Bool) -> (), TVRCButtonType?)?
                    yield &nothing
                    return
                }
                guard let key = key else {
                    var nothing: (Bool, (Bool) -> (), TVRCButtonType?)?
                    yield &nothing
                    return
                }
                yield &packed[modifiers]![key]
            }
        }
        guard storage != nil else {
            return
        }
        if let type = storage!.2 {
            if !pressed {
                pressedButtons.pressed[type] = false
                storage!.0 = false
            } else {
                pressedButtons.pressed[type] = true
                storage!.0 = true
            }
        }
        storage!.1(pressed)
    }
    override func keyDown(with event: NSEvent) {
        process(event, noop: { super.keyDown(with: event) }, pressed: true)
    }
    override func keyUp(with event: NSEvent) {
        process(event, noop: { super.keyUp(with: event) }, pressed: false)
    }
}

/// SwiftUI wrapper for `DeviceButtonResponder`
struct DeviceButtonShortcutHandling: NSViewRepresentable {
    var device: Binding<TVRXDevice>
    var buttons: Binding<[TVRCButton]>
    
    @EnvironmentObject var pressedButtons: PressedButtonContext
    
    struct KeyCombination: Hashable {
        var modifier: EventModifiers
        var key: KeyEquivalent
    }
    
    func makeNSView(context: Context) -> NSViewType {
        let responder = DeviceButtonResponder.shared
        updateNSView(responder, context: context)
        DispatchQueue.main.async {
            responder.window?.makeFirstResponder(responder)
        }
        return responder
    }
    
    func updateNSView(_ responder: NSViewType, context: Context) {
        responder.device = device.wrappedValue
        responder.buttons = buttons.wrappedValue
        responder.pressedButtons = pressedButtons
    }
    
    typealias NSViewType = DeviceButtonResponder
}
