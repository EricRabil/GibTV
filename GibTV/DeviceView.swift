//
//  DeviceView.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import SwiftUI
import TVRemoteCore

struct DeviceView: View {
    @Binding var device: TVRXDevice
    @Binding var buttons: [TVRCButton]
    @Binding var editingContext: TVRCKeyboardAttributes?
    
    var fallbackButtons: [TVRCButton] {
        buttons.filter {
            $0.buttonType() == .siri
        }
    }
    
    @StateObject var trackpadCaptureState = TrackpadProxy.shared.state
    
    @State var pressed: PressedButtonContext = PressedButtonContext()
    
    var body: some View {
        VStack {
            DeviceButtonShortcutHandling(device: $device, buttons: $buttons).environmentObject(pressed).frame(maxWidth: 0, maxHeight: 0)
            Text(device.name()).padding(.bottom).font(.title)
            VStack {
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
            }
            TextEditingControl()
            VStack {
                Button("Capture Cursor") {
                    trackpadCaptureState.enabled = true
                }
                Text(trackpadCaptureState.enabled ? "Cursor captured. Press Shift+Escape to release." : "Cursor is not captured.")
                ManagedTrackpadView().backgrounded()
            }.padding(.vertical)
            DeviceButton(type: .siri).padding(.vertical, 5)
        }
            .environmentObject(DeviceContext(device: device))
            .environmentObject(pressed)
    }
}
