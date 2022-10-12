//
//  CoreGibUI.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import SwiftUI

struct BasicEffectView: NSViewRepresentable {
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
    
    let initializer: (NSVisualEffectView) -> ()
    
    func makeNSView(context: Context) -> some NSView {
        let view = NSVisualEffectView()
        view.state = .followsWindowActiveState
        initializer(view)
        return view
    }
}


extension View {
    func backgrounded() -> some View {
        background(BasicEffectView { $0.material = .contentBackground }).cornerRadius(10)
    }
}

