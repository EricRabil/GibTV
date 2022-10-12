//
//  TrackpadView.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import SwiftUI

struct TrackpadView: View {
    private let touchViewSize: CGFloat = 20

    /// Whether the digitizer is currently being pressed.
    @Binding var pressing: Bool
    /// Array of `Touch` structs, each representing a distinct finger on the digitizer and their current location.
    @Binding var touches: [Touch]
    /// Whether the digitizer is currently being monitored and visualized.
    @Binding var enabled: Bool
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                if TrackpadProxy.shared.wantsHiddenCursor {
                    Button("") {
                        self.enabled = false
                    }.hidden().keyboardShortcut(.escape, modifiers: [.shift])
                }

                ForEach(self.touches) { touch in
                    Circle()
                        .foregroundColor(pressing ? Color.blue : Color.green)
                        .frame(width: self.touchViewSize, height: self.touchViewSize)
                        .offset(
                            x: proxy.size.width * touch.normalizedX - self.touchViewSize / 2.0,
                            y: proxy.size.height * touch.normalizedY - self.touchViewSize / 2.0
                        )
                }
            }
        }
    }
}
