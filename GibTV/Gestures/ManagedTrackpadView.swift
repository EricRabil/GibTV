//
//  Fingers.swift
//  GibTV
//
//  Created by Eric Rabil on 1/30/22.
//

import SwiftUI
import AppKit
import CoreGraphics
import Combine

struct ManagedTrackpadView: View {
    @StateObject var trackpadState = TrackpadProxy.shared.state
    
    /// Whether the digitizer is currently being pressed.
    @State var pressing: Bool = false
    /// Array of `Touch` structs, each representing a distinct finger on the digitizer and their current location.
    @State var touches: [Touch] = []
    
    var body: some View {
        TrackpadView(pressing: $pressing, touches: $touches, enabled: $trackpadState.enabled)
            .aspectRatio(1.6, contentMode: .fit)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onDisappear {
                trackpadState.enabled = false
            }
            .onExitCommand {
                trackpadState.enabled = false
            }
            .onReceive(TrackpadProxy.shared.touchPublisher) { touch in
                switch touch.phase {
                case .ended, .cancelled:
                    self.touches.removeAll(where: { $0.id == touch.index })
                default:
                    self.touches = self.touches.filter { $0.id != touch.index } + [Touch(touch)]
                }
            }
            .onReceive(TrackpadProxy.shared.selectPublisher) { event in
                self.pressing = event == .down
            }
    }
}
