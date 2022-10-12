//
//  GibTVQueryController.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import TVRemoteCore

class GibTVRXDelegate: NSObject, TVRXDeviceQueryDelegate, TVRXDeviceDelegate, TVRXKeyboardControllerDelegate,  ObservableObject {
    static let shared = GibTVRXDelegate()
    
    var devicesByID: [String: TVRXDevice] {
        _read {
            yield GibTVState.shared.devicesByID
        }
        _modify {
            yield &GibTVState.shared.devicesByID
        }
    }
    
    private var keyboardControllers: [TVRXKeyboardController: TVRXDevice] = [:]
    
    func deviceConnected(_ device: TVRXDevice) {
        devicesByID[device.id] = device
        keyboardControllers[device.keyboardController()] = device
        device.setDelegate(self)
        device.keyboardController().setDelegate(self)
    }
    
    func device(_ device: TVRXDevice, updatedSupportedButtons buttons: Set<TVRCButton>) {
        GibTVState.shared.deviceButtons[device.id] = Array(buttons)
    }
    
    func keyboardController(_ keyboardController: TVRXKeyboardController, didUpdateText updatedText: String) {
        guard let device = keyboardControllers[keyboardController] else {
            return
        }
        GibTVState.shared.activeEditingTexts[device] = updatedText
    }
    
    func keyboardController(_ keyboardController: TVRXKeyboardController, didUpdate updatedAttributes: TVRCKeyboardAttributes) {
        guard let device = keyboardControllers[keyboardController] else {
            return
        }
        GibTVState.shared.editingContexts[device] = updatedAttributes
        DispatchQueue.main.async {
            GibTVState.shared.activeEditingTexts[device] = keyboardController.text()
        }
    }
    
    func keyboardControllerEndedTextEditing(_ keyboardController: TVRXKeyboardController) {
        guard let device = keyboardControllers[keyboardController] else {
            return
        }
        GibTVState.shared.activeKeyboardControllers.removeValue(forKey: device)
        GibTVState.shared.editingContexts.removeValue(forKey: device)
        GibTVState.shared.activeEditingTexts.removeValue(forKey: device)
    }
    
    func keyboardController(_ keyboardController: TVRXKeyboardController, beganTextEditingWith attributes: TVRCKeyboardAttributes) {
        guard let device = keyboardControllers[keyboardController] else {
            return
        }
        GibTVState.shared.activeKeyboardControllers[device] = keyboardController
        GibTVState.shared.editingContexts[device] = attributes
        GibTVState.shared.activeEditingTexts[device] = keyboardController.text()
    }
    
    func device(_ device: TVRXDevice, disconnectedForReason arg2: Int64, error arg3: Error) {
        devicesByID.removeValue(forKey: device.id)
    }
    
    func deviceQueryDidUpdateDevices(_ query: TVRXDeviceQuery) {
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
