//
//  GibTVApp.swift
//  GibTV
//
//  Created by Eric Rabil on 1/29/22.
//

import SwiftUI
import Combine

extension TVRCButtonType {
    var description: String {
        TVRCButtonTypeDescription(self)
    }
}

protocol ObjCIdentifiable: Identifiable {
    func identifier() -> String
}

extension ObjCIdentifiable {
    var id: String {
        identifier()
    }
}

extension _TVRXDevice: ObjCIdentifiable {}
extension _TVRXDevice {
    var supportedButtons: [TVRCButton] {
        supportedButtons().array
    }
}

extension Collection {
    var array: [Element] {
        Array(self)
    }
}

extension Collection {
    func dictionary<Key: Hashable, Value>(keyedBy: KeyPath<Element, Key>, valuedBy: KeyPath<Element, Value>) -> [Key: Value] {
        reduce(into: [Key: Value]()) { dict, element in
            dict[element[keyPath: keyedBy]] = element[keyPath: valuedBy]
        }
    }
    
    func dictionary<Key: Hashable>(keyedBy: KeyPath<Element, Key>) -> [Key: Element] {
        dictionary(keyedBy: keyedBy, valuedBy: \.self)
    }
}

class GibTVState: ObservableObject {
    static let shared = GibTVState()
    
    @Published
    var devicesByID: [String: _TVRXDevice] = [:] {
        didSet {
            devices = devicesByID.values.array
            deviceButtons = devicesByID.mapValues(\.supportedButtons)
        }
    }
    
    @Published
    var deviceButtons: [String: [TVRCButton]] = [:]
    
    @Published
    var editingContexts: [_TVRXDevice: TVRCKeyboardAttributes] = [:]
    
    @Published
    var activeKeyboardControllers: [_TVRXDevice: _TVRXKeyboardController] = [:]
    
    @Published
    var activeEditingTexts: [_TVRXDevice: String] = [:]
    
    @Published
    private(set) var devices: [_TVRXDevice] = []
}

class GibTVQueryController: NSObject, _TVRXDeviceQueryDelegate, _TVRXDeviceDelegate, _TVRXKeyboardControllerDelegate,  ObservableObject {
    static let shared = GibTVQueryController()
    
    var devicesByID: [String: _TVRXDevice] {
        _read {
            yield GibTVState.shared.devicesByID
        }
        _modify {
            yield &GibTVState.shared.devicesByID
        }
    }
    
    private var keyboardControllers: [_TVRXKeyboardController: _TVRXDevice] = [:]
    
    func deviceConnected(_ device: _TVRXDevice) {
        devicesByID[device.identifier()] = device
        keyboardControllers[device.keyboardController()] = device
        device.setDelegate(self)
        device.keyboardController().setDelegate(self)
    }
    
    func device(_ device: _TVRXDevice, updatedSupportedButtons buttons: Set<TVRCButton>) {
        GibTVState.shared.deviceButtons[device.id] = buttons.array
    }
    
    func keyboardController(_ keyboardController: _TVRXKeyboardController, didUpdateText updatedText: String) {
        guard let device = keyboardControllers[keyboardController] else {
            return
        }
        GibTVState.shared.activeEditingTexts[device] = updatedText
    }
    
    func keyboardController(_ keyboardController: _TVRXKeyboardController, didUpdate updatedAttributes: TVRCKeyboardAttributes) {
        guard let device = keyboardControllers[keyboardController] else {
            return
        }
        GibTVState.shared.editingContexts[device] = updatedAttributes
    }
    
    func keyboardControllerEndedTextEditing(_ keyboardController: _TVRXKeyboardController) {
        guard let device = keyboardControllers[keyboardController] else {
            return
        }
        GibTVState.shared.activeKeyboardControllers.removeValue(forKey: device)
        GibTVState.shared.editingContexts.removeValue(forKey: device)
        GibTVState.shared.activeEditingTexts.removeValue(forKey: device)
    }
    
    func keyboardController(_ keyboardController: _TVRXKeyboardController, beganTextEditingWith attributes: TVRCKeyboardAttributes) {
        guard let device = keyboardControllers[keyboardController] else {
            return
        }
        GibTVState.shared.activeKeyboardControllers[device] = keyboardController
        GibTVState.shared.editingContexts[device] = attributes
        GibTVState.shared.activeEditingTexts[device] = keyboardController.text()
    }
    
    func device(_ device: _TVRXDevice, disconnectedForReason arg2: Int64, error arg3: Error) {
        devicesByID.removeValue(forKey: device.identifier())
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
                deviceConnected(device)
            }
        }
    }
}

class GibTVApplicationDelegate: NSObject, NSApplicationDelegate {
//    static let shared = GibTVApplicationDelegate()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let window = NSApp.windows.first else {
            fatalError()
        }
        window.level = .floating
    }
}

@main
struct GibTVApp: App {
    lazy var query = _TVRXDeviceQuery()
    
    var cancellables: Set<AnyCancellable> = Set()
    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @NSApplicationDelegateAdaptor(GibTVApplicationDelegate.self) var appDelegate
    
    init() {
        UserDefaults(suiteName: "com.apple.mediaremote")!.set(true, forKey: "MRExternalDeviceIncludePeerToPeer")
        
        query.setDelegate(GibTVQueryController.shared)
        query.start()
        
        RemoteTouchCollector.touchPublisher.sink { event in
            GibTVState.shared.devices.first?.send(event)
        }.store(in: &cancellables)
        RemoteTouchCollector.selectPublisher.sink { event in
            switch event {
            case .down:
                GibTVState.shared.devices.first?.trigger(button: .select, type: .pressed)
            case .up:
                GibTVState.shared.devices.first?.trigger(button: .select, type: .released)
            }
        }.store(in: &cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
