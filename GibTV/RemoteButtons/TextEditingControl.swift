//
//  TextEditingControl.swift
//  GibTV
//
//  Created by Eric Rabil on 1/30/22.
//

import SwiftUI
import Combine

struct TextEditingControl: View {
    @Binding var device: _TVRXDevice
    @State private var canEdit: Bool = false
    @StateObject private var state = GibTVState.shared
    
    func submit() {
        guard device.keyboardController().isEditing() else {
            return
        }
        device.keyboardController().sendReturnKey()
    }
    
    var body: some View {
        HStack {
            TextField("Text", text: createDeviceTextBinding()).padding().backgrounded()
            Button.init("Go", role: nil, action: { }).padding()
        }.disabled(!state.activeEditingTexts.keys.contains(device))
    }
    
    func createDeviceTextBinding() -> Binding<String> {
        Binding(get: {
            guard device.keyboardController().isEditing() else {
                return ""
            }
            let controller = device.keyboardController()
            let impl = controller.value(forKey: "impl") as! _TVRXKeyboardImpl
            let documentstate = impl.currentSession().documentState.documentState
            return documentstate.contextBeforeInput + documentstate.markedText + documentstate.selectedText + documentstate.contextAfterInput
        }, set: { newText in
            guard device.keyboardController().isEditing() else {
                return
            }
            if device.keyboardController().text() == newText {
                return
            }
            let keyboardController = device.keyboardController()
            let impl = keyboardController.value(forKey: "impl") as! _TVRXKeyboardImpl
            let session = impl.currentSession()
            session.documentState.documentState.applyTextOperations(usingUpdatedLocalText: newText, operations: session.textOperations)
            session.flushOperations()
        })
    }
}
