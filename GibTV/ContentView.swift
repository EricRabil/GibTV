//
//  ContentView.swift
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

import SwiftUI
import WrappingHStack

extension _TVRXDevice: Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

extension TVRCButton: Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
    
    func event(type: TVRCButtonEventType) -> TVRCButtonEvent {
        TVRCButtonEvent(for: self, eventType: type)
    }
}

extension TVRCButtonType: Comparable {
    public static func < (lhs: TVRCButtonType, rhs: TVRCButtonType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public static func > (lhs: TVRCButtonType, rhs: TVRCButtonType) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}

extension _TVRXDevice {
    func button(withType type: TVRCButtonType) -> TVRCButton? {
        supportedButtons().first(where: {
            $0.buttonType() == type
        })
    }
    
    func press(button buttonType: TVRCButtonType) {
        trigger(button: buttonType, type: .buttonDown)
    }
    
    func trigger(button buttonType: TVRCButtonType, type eventType: TVRCButtonEventType) {
        guard let button = button(withType: buttonType) else {
            return
        }
        send(button.event(type: eventType))
    }
}

struct DeviceView: View {
    @Binding var device: _TVRXDevice
    @Binding var buttons: [TVRCButton]
    @Binding var editingContext: TVRCKeyboardAttributes?
    
    struct DeviceButton: View {
        @Binding var device: _TVRXDevice
        var button: TVRCButton
        var title: String
        
        init(device: Binding<_TVRXDevice>, button: TVRCButton) {
            self._device = device
            self.button = button
            self.title = button.buttonType().description
        }
        
        var body: some View {
            Button(title) {
                device.send(button.event(type: .buttonDown))
            }
        }
    }
    
    struct PowerControls: View {
        @Binding var device: _TVRXDevice
        
        static var delegatedButtonTypes: [TVRCButtonType] = [.power, .sleep, .wake]
        
        func power() {
            device.press(button: .power)
        }
        
        func sleep() {
            device.press(button: .sleep)
        }
        
        func wake() {
            device.press(button: .wake)
        }
        
        var body: some View {
            HStack {
                Button(action: power) {
                    Text("Power")
                }
                Button(action: sleep) {
                    Text("Sleep")
                }
                Button(action: wake) {
                    Text("Wake")
                }
            }
        }
    }
    
    struct PlaybackControls: View {
        @Binding var device: _TVRXDevice
        
        static var delegatedButtonTypes: [TVRCButtonType] = [.playPause, .volumeUp, .volumeDown, .mute]
        
        func toggle() {
            device.press(button: .playPause)
        }
        
        func volumeUp() {
            device.press(button: .volumeUp)
        }
        
        func volumeDown() {
            device.press(button: .volumeDown)
        }
        
        func mute() {
            device.press(button: .mute)
        }
        
        var body: some View {
            VStack {
                HStack {
                    Button(action: volumeDown) {
                        Image(systemName: "minus")
                    }.keyboardShortcut(.downArrow, modifiers: [.command])
                    Button(action: toggle) {
                        Image(systemName: "playpause")
                    }.keyboardShortcut(.space, modifiers: [])
                    Button(action: volumeUp) {
                        Image(systemName: "plus")
                    }.keyboardShortcut(.upArrow, modifiers: [.command])
                }
                Button(action: mute) {
                    Image(systemName: "speaker.slash")
                }
            }
        }
    }
    
    struct NavigationControls: View {
        @Binding var device: _TVRXDevice
        
        static var delegatedButtonTypes: [TVRCButtonType] = [.arrowUp, .arrowDown, .arrowLeft, .arrowRight, .select, .menu, .home]
        
        func up() {
            device.press(button: .arrowUp)
        }
        
        func down() {
            device.press(button: .arrowDown)
        }
        
        func left() {
            device.press(button: .arrowLeft)
        }
        
        func right() {
            device.press(button: .arrowRight)
        }
        
        func select() {
            device.press(button: .select)
        }
        
        func menu() {
            device.press(button: .menu)
        }
        
        func home() {
            device.press(button: .home)
        }
        
        var body: some View {
            VStack {
                HStack {
                    Button(action: self.left) {
                        Image(systemName: "chevron.left")
                    }.keyboardShortcut(.leftArrow, modifiers: [])
                    VStack {
                        Button(action: self.up) {
                            Image(systemName: "chevron.up")
                        }.keyboardShortcut(.upArrow, modifiers: [])
                        Button(action: self.down) {
                            Image(systemName: "chevron.down")
                        }.keyboardShortcut(.downArrow, modifiers: [])
                    }
                    Button(action: self.right) {
                        Image(systemName: "chevron.right")
                    }.keyboardShortcut(.rightArrow, modifiers: [])
                }
                HStack {
                    Button(action: self.menu) {
                        Text("Menu")
                    }.keyboardShortcut(.escape, modifiers: [])
                    Button(action: self.select) {
                        Text("Select")
                    }.keyboardShortcut(.return, modifiers: [])
                }
                Button(action: self.home) {
                    Image(systemName: "tv")
                }
            }
        }
    }
    
    struct TextEditingControl: View {
        @Binding var device: _TVRXDevice
        @Binding var editingContext: TVRCKeyboardAttributes? {
            didSet {
                if device.keyboardController().isEditing() {
                    boundText = device.keyboardController().text()
                } else {
                    boundText = ""
                }
            }
        }
        
        @State var boundText: String = "" {
            didSet {
                guard device.keyboardController().isEditing() else {
                    return
                }
                if device.keyboardController().text() == boundText {
                    return
                }
                device.keyboardController().setText(boundText)
            }
        }
        
        func submit() {
            guard device.keyboardController().isEditing() else {
                return
            }
            device.keyboardController().sendReturnKey()
        }
        
        var body: some View {
            HStack {
                TextField("Text", text: $boundText)
                Button(action: submit) {
                    Text("Submit")
                }
            }
        }
    }
    
    var delegatedButtonTypes: [TVRCButtonType] {
        PlaybackControls.delegatedButtonTypes + NavigationControls.delegatedButtonTypes + PowerControls.delegatedButtonTypes
    }
    
    var fallbackButtons: [TVRCButton] {
        buttons.filter {
            $0.buttonType() == .siri
        }
    }
    
    var body: some View {
        VStack {
            Text(device.name())
            PowerControls(device: $device)
            PlaybackControls(device: $device)
            NavigationControls(device: $device)
            TextEditingControl(device: $device, editingContext: $editingContext).disabled(editingContext == nil)
            VStack {
                Button("Capture Cursor") {
                    CursorManager.shared.start()
                }
                TrackPadViewController(device: $device)
            }
            WrappingHStack(fallbackButtons, spacing: .dynamicIncludingBorders(minSpacing: 5)) { button in
                DeviceButton(device: $device, button: button)
                    .padding(.vertical, 5)
            }.padding()
        }
    }
}

extension ObservableObject {
    func binding<Key: Hashable, Value>(forDictionary dictionary: ReferenceWritableKeyPath<Self, [Key: Value]>, atKey key: Key, defaultValue: @autoclosure @escaping () -> Value) -> Binding<Value> {
        Binding(get: {
            return self[keyPath: dictionary][key] ?? defaultValue()
        }, set: {
            self[keyPath: dictionary][key] = $0
        })
    }
    
    func binding<Key: Hashable, Value>(forDictionary dictionary: ReferenceWritableKeyPath<Self, [Key: Value]>, atKey key: Key) -> Binding<Value?> {
        Binding(get: {
            return self[keyPath: dictionary][key]
        }, set: {
            self[keyPath: dictionary][key] = $0
        })
    }
}

extension _TVRXDevice {
    var binding: Binding<_TVRXDevice> {
        GibTVState.shared.binding(forDictionary: \.devicesByID, atKey: id, defaultValue: _TVRXDevice())
    }
    
    var binding_supportedButtons: Binding<[TVRCButton]> {
        GibTVState.shared.binding(forDictionary: \.deviceButtons, atKey: id, defaultValue: [])
    }
    
    var binding_editingContext: Binding<TVRCKeyboardAttributes?> {
        GibTVState.shared.binding(forDictionary: \.editingContexts, atKey: self)
    }
}

struct ContentView: View {
    @StateObject var state = GibTVState.shared
    
    var body: some View {
        List {
            ForEach(state.devices) { device in
                DeviceView(device: device.binding, buttons: device.binding_supportedButtons, editingContext: device.binding_editingContext)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
