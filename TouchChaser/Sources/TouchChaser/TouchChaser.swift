//
//  TouchChaser.swift
//
//  Created by Casper Zandbergen on 14/11/2019.
//

import SwiftUI

@available(iOS 13.0, *)
extension View {
    /// Adds a touch indicator over the current View.
    public func addTouchChaser(_ setting: TouchChaser.Setting) -> some View {
        _ = UIWindow.swizzleOnce
        TouchChaser.setting = setting
        return ZStack {
            self
            TouchChaserView()
        }
    }
}

@available(iOS 13.0, *)
fileprivate struct TouchChaserView: View {
    @ObservedObject var touch = TouchChaser.shared
    
    var body: some View {
        ZStack {
            ForEach(Array(touch.touches.values)) {
                TouchCursor(touch: $0).id($0.id)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

@available(iOS 13.0, *)
fileprivate struct TouchCursor: View {
    @ObservedObject var touch: TouchChaser.Touch
    
    @Environment(\.colorScheme) private var colorScheme
    
    let circleSize: CGFloat = 30
    
    var body: some View {
        ZStack(alignment: .center) {
            DragShape(points: touch.points)
                .fill()
                .opacity(touch.ended ? 0 : 0.4)
                .animation(.spring())
        }
    }
}

@available(iOS 13.0, *)
public class TouchChaser: ObservableObject {
    public enum Setting {
        case inDebug, always, whenRecording
        
        var enabled: Bool {
            switch self {
            case .always:
                return true
            case .inDebug:
                #if DEBUG
                    return true
                #else
                    return false
                #endif
            case .whenRecording:
                return UIScreen.main.isCaptured
            }
        }
    }
    fileprivate static var setting: Setting = .always
    fileprivate static var shared = TouchChaser()
    private init() {}
    fileprivate class Touch: ObservableObject, Identifiable {
        @Published var points: [CGPoint]
        @Published var ended = false
        let id: Int
        
        init(from uiTouch: UITouch) {
            let location = uiTouch.location(in: nil)
            self.points = [location, location, location, location]
            self.id = uiTouch.hash
            
            let timer = Timer(timeInterval: 0.03, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        }
        
        @objc private func update(timer: Timer) {
            if self.points.count > 20 {
                self.points.removeFirst(4)
            } else if self.points.count > 10 {
                self.points.removeFirst(3)
            } else if self.points.count > 1 {
                self.points.removeFirst()
            } else if self.points.count == 1 && self.ended == true {
                self.points.removeFirst()
                timer.invalidate()
                TouchChaser.shared.touches[id] = nil
            }
        }
    }
    
    @Published fileprivate var touches: [Int: Touch] = [:]
}

@available(iOS 13.0, *)
extension UIWindow {
    fileprivate static var swizzleOnce: Void = {
        guard let original = class_getInstanceMethod(UIWindow.self, #selector(UIWindow.sendEvent(_:))) else { return }
        guard let new = class_getInstanceMethod(UIWindow.self, #selector(UIWindow.swizzled_sendEvent(_:))) else { return }
        method_exchangeImplementations(original, new)
    }()
    
    @objc private func swizzled_sendEvent(_ event: UIEvent) {
        self.swizzled_sendEvent(event)
        guard TouchChaser.setting.enabled else { return endAllTouches() }
        event.allTouches?.forEach {
            switch $0.phase {
            case .began: touchBegan($0)
            case .moved, .stationary: touchMoved($0)
            case .cancelled, .ended: touchEnded($0)
            case .regionEntered, .regionMoved, .regionExited: break
            @unknown default: assertionFailure("Implement this")
            }
        }
    }
    
    // sadly doesnt work ??
//    @_dynamicReplacement(for: sendEvent)
//    open func replacedSendEvent(_ event: UIEvent) {
//        sendEvent(event)
//        event.allTouches?.forEach {
//            switch $0.phase {
//            case .began: touchBegan($0)
//            case .moved, .stationary: touchMoved($0)
//            case .cancelled, .ended: touchEnded($0)
//            @unknown default: assertionFailure("Implement this")
//            }
//        }
//    }
    
    private func touchBegan(_ uiTouch: UITouch) {
        TouchChaser.shared.touches[uiTouch.hash] = TouchChaser.Touch(from: uiTouch)
    }
    
    private func touchMoved(_ uiTouch: UITouch) {
        guard let touch = TouchChaser.shared.touches[uiTouch.hash] else { return }
        touch.points.append(uiTouch.location(in: self))
    }
    
    private func touchEnded(_ uiTouch: UITouch) {
        guard let touch = TouchChaser.shared.touches[uiTouch.hash] else { return }
        touch.points.append(uiTouch.location(in: self))
        touch.ended = true
    }
    
    private func endAllTouches() {
        TouchChaser.shared.touches.values.forEach {
            if !$0.ended {
                $0.ended = true
            }
        }
    }
}
