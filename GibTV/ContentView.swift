//
//  ContentView.swift
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

import SwiftUI
import WrappingHStack
import Combine

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
    
    var fallbackButtons: [TVRCButton] {
        buttons.filter {
            $0.buttonType() == .siri
        }
    }
    
    @StateObject var trackpadCaptureState = TrackpadProxy.shared.state
    
    var body: some View {
        VStack {
            Text(device.name()).padding(.bottom).font(.title)
            HStack {
                DeviceButton(type: .power)
                DeviceButton(type: .sleep)
                DeviceButton(type: .wake)
            }
            VStack {
                HStack {
                    DeviceButton(type: .volumeDown)
                    DeviceButton(type: .playPause)
                    DeviceButton(type: .volumeUp)
                }
                DeviceButton(type: .mute)
            }
            VStack {
                HStack {
                    DeviceButton(type: .arrowLeft)
                    VStack {
                        DeviceButton(type: .arrowUp)
                        DeviceButton(type: .arrowDown)
                    }
                    DeviceButton(type: .arrowRight)
                }
                HStack {
                    DeviceButton(type: .menu)
                    DeviceButton(type: .select)
                }
                DeviceButton(type: .home)
            }.padding(.bottom)
            TextEditingControl(device: $device)
            VStack {
                Button("Capture Cursor") {
                    trackpadCaptureState.enabled = true
                }
                Text(trackpadCaptureState.enabled ? "Cursor captured. Press Shift+Escape to release." : "Cursor is not captured.")
                TrackPadViewController(device: $device).backgrounded()
            }.padding(.vertical)
            DeviceButton(type: .siri).padding(.vertical, 5)
        }.environmentObject(DeviceContext(device: device))
    }
}

extension View {
    func backgrounded() -> some View {
        background(VisualEffect()).cornerRadius(10)
    }
}

extension String {
    func slice(start: Int) -> String {
        guard start < (count - 1) else {
            return ""
        }
        return String(self[index(startIndex, offsetBy: start)...])
    }
}

extension TIDocumentState {
    func wholeText() -> String {
        contextBeforeInput + markedText + selectedText + contextAfterInput
    }
    
    func applyTextOperations(usingUpdatedLocalText text: String, operations: RTITextOperations) {
        let wholeText = wholeText()
        if text == wholeText {
            return
        }
        
        if text.starts(with: wholeText) {
            let insertionText = text.slice(start: wholeText.count)
            operations.keyboardOutput.insertText(insertionText)
            return
        }
        
        
        
//        let documentstate = impl.currentSession().documentState.documentState
//        let oldText = documentstate.contextBeforeInput + documentstate.markedText + documentstate.selectedText + documentstate.contextAfterInput
//        let count = oldText.count
//
//        if newText.starts(with: oldText) {
//            let addedText = newText[newText.index(newText.startIndex, offsetBy: oldText.count)...]
//            session.textOperations.insertText(String(addedText), replacementRange: session.textOperations.selectionRangeToAssert)
//        } else {
//            // see if they just deleted a character
//            var deletedCharacters = 0
//
//        }
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
    
    func a() {
        
    }
    
    var body: some View {
        List {
            ForEach(state.devices) { device in
                DeviceView(device: device.binding, buttons: device.binding_supportedButtons, editingContext: device.binding_editingContext)
            }
        }.listStyle(SidebarListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
