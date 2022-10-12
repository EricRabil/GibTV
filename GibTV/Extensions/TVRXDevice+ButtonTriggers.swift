//
//  TVRXDevice+ButtonTriggers.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import TVRemoteCore

extension TVRXDevice {
    func button(withType type: TVRCButtonType) -> TVRCButton? {
        supportedButtons().first(where: {
            $0.buttonType() == type
        })
    }
    
    func press(button buttonType: TVRCButtonType) {
        trigger(button: buttonType, type: .pressed)
    }
    
    func hold(button buttonType: TVRCButtonType) {
        trigger(button: buttonType, type: .buttonDown)
    }
    
    func release(button buttonType: TVRCButtonType) {
        trigger(button: buttonType, type: .released)
    }
    
    func trigger(button buttonType: TVRCButtonType, type eventType: TVRCButtonEventType) {
        guard let button = button(withType: buttonType) else {
            return
        }
        send(TVRCButtonEvent(for: button, eventType: eventType))
    }
}
