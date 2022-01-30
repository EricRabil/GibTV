//
//  GibTVApp.swift
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

import SwiftUI

extension TVRCButtonType {
    var description: String {
        TVRCButtonTypeDescription(self)
    }
}

class GibTVQueryController: NSObject, _TVRXDeviceQueryDelegate, _TVRXDeviceDelegate, ObservableObject {
    static let shared = GibTVQueryController()
    
    @Published
    var devices: [_TVRXDevice] = []
    
//    func pokeDevice(_ device: _TVRXDevice) {
//        print(device.connectionState())
//        for button in device.supportedButtons() {
//            switch button.buttonType() {
//            case .playPause:
//                let event = TVRCButtonEvent(for: button, eventType: .buttonDown)
//                device.send(event)
//            default:
//                break
//            }
//        }
//    }
    
    func deviceConnected(_ device: _TVRXDevice) {
//        pokeDevice(device)
        devices.append(device)
    }
    
    func deviceQueryDidUpdateDevices(_ query: _TVRXDeviceQuery) {
        for device in query.devices() {
            guard device.paired() else {
                continue
            }
            device.setDelegate(self)
            if device.connectionState() == 0 {
                device.connect()
            } else if device.connectionState() == 2 {
                devices.append(device)
            }
        }
    }
}

@main
struct GibTVApp: App {
    lazy var query = _TVRXDeviceQuery()
    
    init() {
        print("bitchhhh")
        
        UserDefaults(suiteName: "com.apple.mediaremote")!.set(true, forKey: "MRExternalDeviceIncludePeerToPeer")
        
        query.setDelegate(GibTVQueryController.shared)
        query.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
