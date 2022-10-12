//
//  DeviceButton.swift
//  GibTV
//
//  Created by Eric Rabil on 1/30/22.
//

import SwiftUI
import TVRemoteCore

private extension View {
    func applyProperties(_ type: TVRCButtonType) -> some View {
        var view: AnyView = AnyView(self)
        if let props = ButtonProperty.properties[type] {
            for prop in props {
                switch prop {
                case .keyboardShortcut(let key, let modifiers):
                    view = AnyView(view.keyboardShortcut(key, modifiers: modifiers))
                }
            }
        }
        return view
    }
}

class DeviceContext: ObservableObject {
    @Published var device: TVRXDevice
    
    init(device: TVRXDevice) {
        self.device = device
    }
}

/// A control mapping to exactly one triggerable button on a `TVRXDevice`
struct DeviceButton: View {
    @EnvironmentObject var deviceContext: DeviceContext
    @EnvironmentObject var pressedButtons: PressedButtonContext
    
    @State private var disabled = false
    @State private var suppressNextAction = false
    
    let buttonType: TVRCButtonType
    let presentationStyle: DeviceButtonPresentationStyle
    
    init(type: TVRCButtonType) {
        buttonType = type
        presentationStyle = type.presentationStyle
    }
    
    var pressed: Bool {
        get {
            pressedButtons.pressed[buttonType, default: false]
        }
        set {
            pressedButtons.pressed[buttonType] = newValue
        }
    }
    
    var device: TVRXDevice {
        deviceContext.device
    }
    
    var button: TVRCButton? {
        device.button(withType: buttonType)
    }
    
    var body: some View {
        Group {
            switch presentationStyle {
            case .systemImage(let string):
                Image(systemName: string)
            case .text(let string):
                Text(string)
            }
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .padding()
        .background(pressed ? Color.accentColor : .white)
        .cornerRadius(5)
        .applyProperties(buttonType)
        ._onButtonGesture(pressing: { pressing in
            self.pressedButtons.pressed[self.buttonType] = pressing
            if pressing {
                send(event: .pressed)
            } else {
                send(event: .released)
                suppressNextAction = true
            }
        }, perform: {
            if suppressNextAction {
                suppressNextAction = false
                return
            }
        })
        .disabled(disabled)
        .onChange(of: deviceContext.device.supportedButtons(), perform: { buttons in
            disabled = !buttons.lazy.map { $0.buttonType() }.contains(buttonType)
        })
    }
    
    func send(event: TVRCButtonEventType) {
        guard let button = button else {
            return
        }
        device.send(.init(for: button, eventType: event))
    }
}
