//
//  ContentView.swift
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

import SwiftUI
import WrappingHStack
import Combine
import TVRemoteCore
import TextInput
import RemoteTextInput

class PressedButtonContext: ObservableObject {
    @Published var pressed: [TVRCButtonType: Bool] = [:]
}

struct ContentView: View {
    @StateObject var state = GibTVState.shared
    
    var body: some View {
        VStack {
            ForEach(state.devices) { device in
                DeviceView(device: device.binding, buttons: device.binding_supportedButtons, editingContext: device.binding_editingContext)
                    .padding()
            }
        }
        .padding()
        .background(BasicEffectView { $0.material = .underWindowBackground }.ignoresSafeArea(.all))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
