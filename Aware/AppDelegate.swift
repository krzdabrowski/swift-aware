//
//  AppDelegate.swift
//  Aware
//
//  Created by Joshua Peek on 12/06/15.
//  Copyright © 2015 Joshua Peek. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var timerStart: DispatchTime = .now()

    // Redraw button every minute
    private let buttonRefreshRate: TimeInterval = 0.1

    // Reference to installed global mouse event monitor
    private var mouseEventMonitor: Any?

    // Default value to initialize userIdleSeconds to
    private static let defaultUserIdleSeconds: TimeInterval = 120

    // User configurable idle time in seconds (defaults to 2 minutes)
    private var userIdleSeconds: TimeInterval = defaultUserIdleSeconds

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    @IBOutlet weak var menu: NSMenu! {
        didSet { statusItem.menu = menu }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.userIdleSeconds = self.readUserIdleSeconds()

        updateButton()

        let timer = Timer.scheduledTimer(buttonRefreshRate, userInfo: nil, repeats: true) { _ in self.updateButton() }
        RunLoop.current.add(timer, forMode: .common)

        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil) { _ in self.resetTimer() }
        notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { _ in self.resetTimer() }
    }
}

extension AppDelegate {
    private static let userActivityEventTypes: [CGEventType] = [
        .leftMouseDown,
        .rightMouseDown,
        .mouseMoved,
        .keyDown,
        .scrollWheel
    ]

    private func resetTimer() {
        timerStart = .now()
        updateButton()
    }

    private func onMouseEvent(_ event: NSEvent) {
        if let eventMonitor = mouseEventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            mouseEventMonitor = nil
        }
        updateButton()
    }

    private func updateButton() {
        let idle: Bool = {
            if sinceUserActivity() > userIdleSeconds {
                timerStart = .now()
                return true
            } else if CGDisplayIsAsleep(CGMainDisplayID()) == 1 {
                timerStart = .now()
                return true
            }
            return false
        }()
        
        if let statusButton = statusItem.button {
            let duration = timerStart.distance(to: .now()).timeInterval
            let title = NSTimeIntervalFormatter().stringFromTimeInterval(duration)
            
            statusButton.title = title
            statusButton.appearsDisabled = idle
        }

        if idle {
            // On next mouse event, immediately update button
            if mouseEventMonitor == nil {
                mouseEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [
                    NSEvent.EventTypeMask.mouseMoved,
                    NSEvent.EventTypeMask.leftMouseDown
                ], handler: onMouseEvent)
            }
        }
    }

    private func sinceUserActivity() -> CFTimeInterval {
        return Self.userActivityEventTypes.map {
            CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: $0)
        }.min()!
    }

    private func readUserIdleSeconds() -> TimeInterval {
        let defaultsValue = UserDefaults.standard.object(forKey: "userIdleSeconds") as? TimeInterval
        return defaultsValue ?? type(of: self).defaultUserIdleSeconds
    }
}
