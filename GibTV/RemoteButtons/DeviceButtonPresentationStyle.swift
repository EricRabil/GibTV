//
//  DeviceButtonPresentationStyle.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import SwiftUI
import TVRemoteCore

enum DeviceButtonPresentationStyle {
    case systemImage(String)
    case text(String)
}

extension TVRCButtonType {
    var presentationStyle: DeviceButtonPresentationStyle {
        switch self {
        case .select:
            return .text("Select")
        case .menu:
            return .text("Menu")
        case .home:
            return .systemImage("tv")
        case .siri:
            return .systemImage("mic")
        case .playPause:
            return .systemImage("playpause")
        case .volumeUp:
            return .systemImage("plus")
        case .volumeDown:
            return .systemImage("minus")
        case .arrowUp:
            return .systemImage("chevron.up")
        case .arrowDown:
            return .systemImage("chevron.down")
        case .arrowLeft:
            return .systemImage("chevron.left")
        case .arrowRight:
            return .systemImage("chevron.right")
        case .captionsToggle:
            return .text("Toggle Captions")
        case .activateScreenSaver:
            return .text("Activate Screen Saver")
        case .launchApplication:
            return .text("Launch Application")
        case .wake:
            return .text("Wake")
        case .sleep:
            return .text("Sleep")
        case .pageUp:
            return .text("Page Up")
        case .pageDown:
            return .text("Page Down")
        case .guide:
            return .text("Guide")
        case .mute:
            return .systemImage("speaker.slash")
        case .power:
            return .text("Power")
        @unknown default:
            return .text(TVRCButtonTypeDescription(self))
        }
    }
}
