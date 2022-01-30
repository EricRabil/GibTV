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

extension NSEvent.EventType {
    var cgEventType: CGEventType {
        CGEventType(rawValue: UInt32(rawValue))!
    }
}

let events: [CGEventType] = [NSEvent.EventType.gesture.cgEventType, NSEvent.EventType.beginGesture.cgEventType, NSEvent.EventType.endGesture.cgEventType, .leftMouseDown, .leftMouseUp]
let eventMask: CGEventMask = events.reduce(0 as CGEventMask) { acc, type in acc | CGEventMask(type.rawValue) }

extension NSTouch.Phase {
    var description: String {
        switch self {
        case .any:
            return "any"
        case .began:
            return "began"
        case .cancelled:
            return "cancelled"
        case .ended:
            return "ended"
        case .moved:
            return "moved"
        case .stationary:
            return "stationary"
        case .touching:
            return "touching"
        default:
            return "NSTouchPhase(rawValue: \(rawValue))"
        }
    }
}

enum SelectAction {
    case down
    case up
}

class RemoteTouchCollector {
    static let shared = RemoteTouchCollector()
    
    private static let subject = PassthroughSubject<TVRCTouchEvent, Never>()
    fileprivate static let selectSubject = PassthroughSubject<SelectAction, Never>()
    private static let nsTouchSubject = PassthroughSubject<NSTouch, Never>()
//    private static
    static let nsTouchPublisher: AnyPublisher<NSTouch, Never> = nsTouchSubject.share().eraseToAnyPublisher()
    static let touchPublisher: AnyPublisher<TVRCTouchEvent, Never> = subject.share().eraseToAnyPublisher()
    static let selectPublisher: AnyPublisher<SelectAction, Never> = selectSubject.share().eraseToAnyPublisher()
    
    static var isDown = false
    
    static var seenEventTypes: Set<CGEventType> = Set()
    static let tapHandler: CGEventTapCallBack = { proxy, type, event, refcon in
        let tvTouchEvent = TVRCTouchEvent()
        
        if type == .tapDisabledByUserInput {
            shared.reenable()
        }
        
        var returnValue: Unmanaged<CGEvent> { Unmanaged.passUnretained(event) }
        
        if !seenEventTypes.contains(type) {
            print(type.rawValue)
            seenEventTypes.insert(type)
        }
        
        switch type {
        case .tapDisabledByUserInput:
            shared.reenable()
            return returnValue
        case .leftMouseDown:
            let nsEvent = NSEvent(cgEvent: event)!
            print(nsEvent)
            isDown = true
            selectSubject.send(.down)
            return returnValue
        case .leftMouseUp:
            isDown = false
            selectSubject.send(.up)
            return returnValue
        case .mouseMoved:
            return returnValue
        case .scrollWheel:
            return returnValue
        default:
            switch type.rawValue {
//            case 19:
//                break
//            case 20:
//                break
            case 29:
                break
            default:
                return returnValue
            }
        }
        
        guard let window = NSApplication.shared.windows.first, window.orderedIndex == 1, let screen = window.screen else {
            return returnValue
        }
        
        let nsEvent = NSEvent(cgEvent: event)!
        
        let location = event.location
        let frame = screen.frame
        
        let touchEvents = nsEvent.allTouches().map { touch -> (TVRCTouchEvent, NSTouch) in
            let timestamp = touch.value(forKey: "timestamp") as! Double
            let phase = touch.phase
            let index = touch.value(forKey: "index") as! CLongLong
            
            let normalizedX = location.x / frame.width
            let normalizedY = location.y / frame.height
            
            var position = touch.normalizedPosition
            position.y = 1 - position.y
            
            return (TVRCTouchEvent()._init(withTimestamp: timestamp, finger: index, phase: Int64(phase.rawValue), digitizerLocation: position), touch)
        }
        
        for (touchEvent, touch) in touchEvents {
            nsTouchSubject.send(touch)
            subject.send(touchEvent)
        }
        
        return returnValue
    }
    
    private func createTap() -> CFMachPort? {
        CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .listenOnly, eventsOfInterest: NSEvent.EventTypeMask.any.rawValue, callback: RemoteTouchCollector.tapHandler, userInfo: nil)
    }
    
    var tap: CFMachPort?
    var source: CFRunLoopSource?
    
    func reenable() {
        if let tap = tap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }
    
    fileprivate func start() {
        if let tap = tap {
            CGEvent.tapEnable(tap: tap, enable: true)
            if let source = source {
                CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
            }
            return
        }
        
        if let tap = createTap() {
            self.tap = tap
            let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            self.source = source
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
            
            CGEvent.tapEnable(tap: tap, enable: true)
        } else {
            fatalError()
        }
    }
    
    fileprivate func stop() {
        if let tap = tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = source {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            }
        }
    }
}

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
        RemoteTouchCollector.nsTouchPublisher.sink { touch in
            switch touch.phase {
            case .ended, .cancelled:
                self.touches.removeAll(where: { $0.id == touch.index })
            default:
                self.touches = self.touches.filter { $0.id != touch.index } + [Touch(touch)]
            }
        }.store(in: &cancellables)
        RemoteTouchCollector.selectPublisher.sink { event in
            self.pressing = event == .down
        }.store(in: &cancellables)
    }
    
    func teardown() {
        cancellables = Set()
    }
    
    var body: some View {
        List {}.onAppear(perform: setup).onDisappear(perform: teardown)
    }
}

@_silgen_name("CGCursorIsVisible")
func CGCursorIsVisible() -> boolean_t

class CursorManager: ObservableObject {
    static let shared = CursorManager()
    
    @Published var active = false
    var cancellables = Set<AnyCancellable>()
    
    func handleMoved() {
        guard active else {
            return
        }
    }
    
    func start() {
        guard !active else {
            return
        }
        active = true
        RemoteTouchCollector.shared.start()
        RemoteTouchCollector.touchPublisher.filter { _ in self.active }.sink { _ in
            if self.active {
                NSCursor.hide()
                if let frame = NSApp.windows.first(where: \.isKeyWindow)?.frame {
                    CGWarpMouseCursorPosition(CGPoint(x: frame.midX, y: frame.midY))
                } else {
                    CGWarpMouseCursorPosition(CGPoint(x: 0, y: 0))
                }
            }
        }.store(in: &cancellables)
    }
    
    func unhide() {
        print("unhide")
        while CGCursorIsVisible() == 0 {
            NSCursor.unhide()
        }
        if RemoteTouchCollector.isDown {
            RemoteTouchCollector.isDown = false
            RemoteTouchCollector.selectSubject.send(.up)
        }
        NSCursor.setHiddenUntilMouseMoves(false)
    }
    
    func stop() {
        guard active else {
            return
        }
        active = false
        unhide()
        RemoteTouchCollector.shared.stop()
        cancellables = Set()
    }
}

struct TrackPadView: View {
    private let touchViewSize: CGFloat = 20

    @Binding var device: _TVRXDevice
    @State var pressing = false
    @State var touches: [Touch] = []

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                TouchesView(touches: self.$touches, pressing: $pressing, device: $device)
                if CursorManager.shared.active {
                    Button("") {
                        CursorManager.shared.stop()
                    }.hidden().keyboardShortcut(.escape, modifiers: [])
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

extension Binding {
    func didSet(_ didSet: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                didSet(newValue)
            }
        )
    }
}

struct TrackPadViewController: View {
    @Binding var device: _TVRXDevice
    
    var body: some View {
        TrackPadView(device: $device)
            .background(Color.gray)
            .aspectRatio(1.6, contentMode: .fit)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onDisappear {
                CursorManager.shared.stop()
            }
            .onExitCommand {
                CursorManager.shared.stop()
            }
    }
}
