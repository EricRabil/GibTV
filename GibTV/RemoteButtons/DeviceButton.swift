//
//  DeviceButton.swift
//  GibTV
//
//  Created by Eric Rabil on 1/30/22.
//

import SwiftUI

enum DeviceButtonPresentationStyle {
    case systemImage(String)
    case text(String)
}

extension TVRCButtonType {
    var presentationStyle: DeviceButtonPresentationStyle {
        switch self {
        case .select:
            return .text("Select")
        case .menu:
            return .text("Menu")
        case .home:
            return .systemImage("tv")
        case .siri:
            return .systemImage("mic")
        case .playPause:
            return .systemImage("playpause")
        case .volumeUp:
            return .systemImage("plus")
        case .volumeDown:
            return .systemImage("minus")
        case .arrowUp:
            return .systemImage("chevron.up")
        case .arrowDown:
            return .systemImage("chevron.down")
        case .arrowLeft:
            return .systemImage("chevron.left")
        case .arrowRight:
            return .systemImage("chevron.right")
        case .captionsToggle:
            return .text("Toggle Captions")
        case .activateScreenSaver:
            return .text("Activate Screen Saver")
        case .launchApplication:
            return .text("Launch Application")
        case .wake:
            return .text("Wake")
        case .sleep:
            return .text("Sleep")
        case .pageUp:
            return .text("Page Up")
        case .pageDown:
            return .text("Page Down")
        case .guide:
            return .text("Guide")
        case .mute:
            return .systemImage("speaker.slash")
        case .power:
            return .text("Power")
        @unknown default:
            return .text(description)
        }
    }
}

enum ButtonProperty {
    case keyboardShortcut(KeyEquivalent, modifiers: EventModifiers)
    
    static func keyboardShortcut(_ key: KeyEquivalent) -> ButtonProperty {
        .keyboardShortcut(key, modifiers: [])
    }
    
    static func keyboardShortcut(modifier: EventModifiers, _ key: KeyEquivalent) -> ButtonProperty {
        .keyboardShortcut(key, modifiers: modifier)
    }
}

var buttonProperties: [TVRCButtonType: [ButtonProperty]] = [
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

private extension View {
    func applyProperties(_ type: TVRCButtonType) -> some View {
        var view: AnyView = AnyView(self)
        if let props = buttonProperties[type] {
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
    @Published var device: _TVRXDevice
    
    init(device: _TVRXDevice) {
        self.device = device
    }
}

protocol DeviceButtonDelegate {
    static var delegatedButtonTypes: [TVRCButtonType] { get }
}

struct DeviceButton: View {
    @EnvironmentObject var deviceContext: DeviceContext
    
    var device: _TVRXDevice {
        deviceContext.device
    }
    
    var buttonType: TVRCButtonType
    
    @State private var disabled = false
    private var presentationStyle: DeviceButtonPresentationStyle
    
    init(type: TVRCButtonType) {
        buttonType = type
        presentationStyle = type.presentationStyle
    }
    
    var body: some View {
        return Button(action: {
            device.press(button: buttonType)
        }) {
            switch presentationStyle {
            case .systemImage(let string):
                Image(systemName: string)
            case .text(let string):
                Text(string)
            }
        }
        .onChange(of: [device.supportedButtons(), buttonType] as [AnyHashable]) { _ in
            disabled = !device.supportedButtons().contains(where: { $0.buttonType() == buttonType })
        }
        .applyProperties(buttonType)
        .disabled(disabled)
    }
}
