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

extension NSTouch {
    var index: Int {
        Int(value(forKey: "index") as! CLongLong)
    }
}

struct Touch: Identifiable {
    // `Identifiable` -> `id` is required for `ForEach` (see below).
    let id: Int
    // Normalized touch X position on a device (0.0 - 1.0).
    let normalizedX: CGFloat
    // Normalized touch Y position on a device (0.0 - 1.0).
    let normalizedY: CGFloat

    init(_ nsTouch: NSTouch) {
        self.normalizedX = nsTouch.normalizedPosition.x
        // `NSTouch.normalizedPosition.y` is flipped -> 0.0 means bottom. But the
        // `Touch` structure is meants to be used with the SwiftUI -> flip it.
        self.normalizedY = 1.0 - nsTouch.normalizedPosition.y
        self.id = nsTouch.index
    }
}

struct TouchesView: View {
    // Up to date list of touching touches.
    @Binding var touches: [Touch]
    @Binding var pressing: Bool
    @Binding var device: _TVRXDevice

    @State var cancellables = Set<AnyCancellable>()
    
    func setup() {
        TrackpadProxy.shared.touchPublisher.sink { touch in
            switch touch.phase {
            case .ended, .cancelled:
                self.touches.removeAll(where: { $0.id == touch.index })
            default:
                self.touches = self.touches.filter { $0.id != touch.index } + [Touch(touch)]
            }
        }.store(in: &cancellables)
        TrackpadProxy.shared.selectPublisher.sink { event in
            self.pressing = event == .down
        }.store(in: &cancellables)
    }
    
    func teardown() {
        cancellables = Set()
    }
    
    var body: some View {
        VStack {}.onAppear(perform: setup).onDisappear(perform: teardown)
    }
}

struct TrackPadView: View {
    private let touchViewSize: CGFloat = 20

    @Binding var device: _TVRXDevice
    @State var pressing = false
    @State var touches: [Touch] = []
    
    @StateObject var trackpadState = TrackpadProxy.shared.state

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                TouchesView(touches: self.$touches, pressing: $pressing, device: $device)
                if TrackpadProxy.shared.wantsHiddenCursor {
                    Button("") {
                        trackpadState.enabled = false
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

struct TrackPadViewController: View {
    @Binding var device: _TVRXDevice
    
    @StateObject var trackpadState = TrackpadProxy.shared.state
    
    var body: some View {
        TrackPadView(device: $device)
            .aspectRatio(1.6, contentMode: .fit)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onDisappear {
                trackpadState.enabled = false
            }
            .onExitCommand {
                trackpadState.enabled = false
            }
    }
}
