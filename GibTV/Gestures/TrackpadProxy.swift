//
//  TrackpadProxy.swift
//  GibTV
//
//  Created by Eric Rabil on 1/30/22.
//

import Foundation
import Combine
import AppKit
import TVRemoteCore

enum SelectAction {
    case down
    case up
}

@_silgen_name("CGCursorIsVisible")
private func CGCursorIsVisible() -> boolean_t

private extension NSScreen {
    var cgScreenID: CGDirectDisplayID? {
        deviceDescription[.init("NSScreenNumber")] as? CGDirectDisplayID
    }
}

class Gib {
    static func window() -> NSWindow? {
        NSApp?.windows.first(where: \.isKeyWindow)
    }
    
    static func screen() -> NSScreen? {
        window()?.screen
    }
}

/// Receives HID events from CoreGraphics and emits touch events for AppKit, TVRemoteCore, and down/up detection.
class TrackpadProxy {
    class State: ObservableObject {
        fileprivate init() {}
        
        @Published var enabled = false
    }

    static let shared = TrackpadProxy()
    
    let state = State()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Cursor
    
    /// Whether we should maintain a hidden/visible cursor at this time.
    private(set) var wantsHiddenCursor = false
    
    // MARK: - Combine
    
    private let gestureEventSubject = PassthroughSubject<NSEvent, Never>()
    private(set) lazy var gestureEventPublisher = gestureEventSubject.share().eraseToAnyPublisher()
    
    private let selectSubject = PassthroughSubject<SelectAction, Never>()
    private(set) lazy var selectPublisher = selectSubject.share().eraseToAnyPublisher()
    
    private let touchSubject = PassthroughSubject<NSTouch, Never>()
    private(set) lazy var touchPublisher = touchSubject.share().eraseToAnyPublisher()
    
    private let tvTouchSubject = PassthroughSubject<TVRCTouchEvent, Never>()
    private(set) lazy var tvTouchPublisher = tvTouchSubject.share().eraseToAnyPublisher()
    
    // MARK: - CGEventTap storage
    
    private var runLoop: CFRunLoop { CFRunLoopGetMain() }
    private lazy var eventTap: CFMachPort = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .listenOnly, eventsOfInterest: NSEvent.EventTypeMask.any.rawValue, callback: TrackpadProxy.eventTapHandler, userInfo: nil)!
    private lazy var eventTapRunLoopSource: CFRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    
    private var eventTapEnabled: Bool {
        CGEvent.tapIsEnabled(tap: eventTap)
    }
    
    private var eventTapRunLoopSourceIsAdded: Bool {
        CFRunLoopContainsSource(runLoop, eventTapRunLoopSource, .commonModes)
    }
    
    init() {
        state.$enabled.sink { proxyEnabled in
            if proxyEnabled {
                self.didEnable()
            } else {
                self.didDisable()
            }
        }.store(in: &cancellables)
        
        gestureEventPublisher.sink { _ in
            self.assertCursor()
        }.store(in: &cancellables)
    }
    
    // MARK: - Lifecycle
    
    private func didEnable() {
        resumeEventTap()
        hideCursor()
    }
    
    private func didDisable() {
        suspendEventTap()
        showCursor()
    }
    
    // MARK: - Cursor
    
    private func eventTapReceivedEvent(_ eventType: CGEventType, _ event: CGEvent) {
        if eventType.meansWeShouldReenableTap {
            resumeEventTap()
            return
        }
        
        if eventType.isSelectEvent {
            selectSubject.send(eventType.isSelectPressedEvent ? .down : .up)
        } else if eventType.isInterestingTouchEvent, let touchEvents = event.touchEvents() {
            for touchEvent in touchEvents {
                touchSubject.send(touchEvent.nsTouch)
                tvTouchSubject.send(touchEvent.tvTouch)
            }
            if let nsEvent = event.nsEvent {
                gestureEventSubject.send(nsEvent)
            }
        }
    }
    
    private var cursorIsVisible: Bool {
        CGCursorIsVisible() == 1
    }
    
    private var cursorIsHidden: Bool {
        !cursorIsVisible
    }
    
    private func assertCursor() {
        if wantsHiddenCursor {
            if !cursorIsHidden {
                hideCursor()
            }
            if let frame = Gib.window()?.frame {
                CGWarpMouseCursorPosition(CGPoint(x: frame.midX, y: frame.midY))
            } else {
                CGWarpMouseCursorPosition(CGPoint(x: 0, y: 0))
            }
        }
    }
    
    private func hideCursor() {
        guard let screen = Gib.screen(), let cgScreenID = screen.cgScreenID else {
            return
        }
        
        if cursorIsHidden {
            return
        }
        
        wantsHiddenCursor = true
        CGDisplayHideCursor(cgScreenID)
    }
    
    private func showCursor() {
        guard let screen = Gib.screen(), let cgScreenID = screen.cgScreenID else {
            return
        }
        
        wantsHiddenCursor = false
        while cursorIsHidden {
            CGDisplayShowCursor(cgScreenID)
        }
    }
    
    // MARK: - CGEventTap setup
    
    private static let eventTapHandler: CGEventTapCallBack = { proxy, type, event, refcon in
        TrackpadProxy.shared.eventTapReceivedEvent(type, event)
        return Unmanaged.passUnretained(event)
    }
    
    private func resumeEventTap() {
        if !eventTapEnabled {
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
        if !eventTapRunLoopSourceIsAdded {
            CFRunLoopAddSource(runLoop, eventTapRunLoopSource, .commonModes)
        }
    }
    
    private func suspendEventTap() {
        if eventTapEnabled {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if eventTapRunLoopSourceIsAdded {
            CFRunLoopRemoveSource(runLoop, eventTapRunLoopSource, .commonModes)
        }
    }
}
