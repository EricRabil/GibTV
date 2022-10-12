//
//  GibTVApp.swift
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

import SwiftUI
import Combine
import TVRemoteCore

@main
struct GibTVApp: App {
    lazy var query = TVRXDeviceQuery()
    
    var cancellables: Set<AnyCancellable> = Set()
    
    /// Required because SwiftUI does not have an easy way to enforce a window's aspect-ratio (afaict).
    class GibAppDelegate: NSObject, NSApplicationDelegate, ObservableObject, NSWindowDelegate {
        func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
            if sender.frame.height == frameSize.height {
                return CGSize(width: frameSize.width, height: frameSize.width * 1/(9/16))
            } else {
                return CGSize(width: frameSize.height * (9/16), height: frameSize.height)
            }
        }
        
        func applicationDidUpdate(_ notification: Notification) {
            for window in NSApplication.shared.windows {
                if window.delegate !== self {
                    window.delegate = self
                }
            }
        }
    }
    
    @NSApplicationDelegateAdaptor private var delegate: GibAppDelegate
    
    init() {
        UserDefaults(suiteName: "com.apple.mediaremote")!.set(true, forKey: "MRExternalDeviceIncludePeerToPeer")
        
        query.setDelegate(GibTVRXDelegate.shared)
        query.start()
        
        TrackpadProxy.shared.tvTouchPublisher.sink { event in
            GibTVState.shared.devices.first?.send(event)
        }.store(in: &cancellables)
        TrackpadProxy.shared.selectPublisher.sink { event in
            switch event {
            case .down:
                GibTVState.shared.devices.first?.trigger(button: .select, type: .buttonDown)
            case .up:
                GibTVState.shared.devices.first?.trigger(button: .select, type: .released)
            }
        }.store(in: &cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 450, minHeight: 800)
                .aspectRatio(9 / 16, contentMode: .fill)
        }.windowStyle(HiddenTitleBarWindowStyle())
    }
}
