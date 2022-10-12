//
//  TextEditingControl.swift
//  GibTV
//
//  Created by Eric Rabil on 1/30/22.
//

import SwiftUI
import Combine
import TVRemoteCore

/// A `TextField` whose value and focus is managed based on `TVRXDevice` state. Text is manipulated using the `RemoteTextInput` framework.
struct TextEditingControl: View {
    @EnvironmentObject var deviceContext: DeviceContext
    @StateObject private var state = GibTVState.shared
    
    @State private var canEdit: Bool = false
    @State private var localText: String = ""
    @FocusState private var focused: Bool
    
    var device: TVRXDevice { deviceContext.device }
    
    var body: some View {
        HStack {
            TextField("Text", text: $localText).focused($focused).padding().backgrounded().onSubmit {
                focused = false
            }
            Button.init("Go", role: nil, action: { }).padding()
        }
            .disabled(!canEdit)
            .onChange(of: localText) {
                let keyboardController = device.keyboardController()
                if $0 != keyboardController.text() {
                    guard keyboardController.isEditing() else {
                        return
                    }
                    guard keyboardController.text() != localText else {
                        return
                    }
                    keyboardController.applyTextOperations(usingUpdatedLocalText: localText)
                }
            }
            .onReceive(state.$activeEditingTexts) { state in
                if let text = state[device], text != localText {
                    localText = text
                    canEdit = true
                } else if state[device] == nil {
                    localText = ""
                    canEdit = false
                    focused = false
                }
            }
            .onChange(of: focused) { focused in
                if !focused {
                    DeviceButtonResponder.shared.window?.makeFirstResponder(DeviceButtonResponder.shared)
                }
            }
            .onAppear {
                localText = state.activeEditingTexts[device] ?? ""
            }
    }
}

private extension TVRXKeyboardController {
    func applyTextOperations(usingUpdatedLocalText newValue: String) {
        let impl = _keyboardImpl()
        
        defer { impl.currentSession().flushOperations() }
        
        impl.currentSession().textOperations.textToAssert = newValue
    }
}
