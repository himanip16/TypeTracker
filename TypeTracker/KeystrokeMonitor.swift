import Foundation
import AppKit

class KeystrokeMonitor {
    
    private var eventMonitor: Any?
    private let statsStore: StatsStore
    
    // Remember when last key was pressed
    private var lastKeystrokeTime: Date?
    
    // Ignore gaps larger than this (user is idle)
    private let idleThreshold: TimeInterval = 2.0
    
    init(statsStore: StatsStore) {
        self.statsStore = statsStore
    }
    
    // Just checks the status without showing the annoying popup
    func hasAccessibilityPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    // Explicitly requests permission (shows the popup)
    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    func startMonitoring() {
        guard eventMonitor == nil else { return }
        
        if hasAccessibilityPermission() {
            
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] _ in
                self?.handleKeyPress()
            }
            
        } else {
            print("TypeTracker: Waiting for accessibility permissions...")
            openAccessibilitySettings()
        }
    }
    
    private func handleKeyPress() {
        let now = Date()
        var elapsed: TimeInterval = 0
        
        if let last = lastKeystrokeTime {
            let diff = now.timeIntervalSince(last)
            
            // Only count time if user is actively typing
            if diff <= idleThreshold {
                elapsed = diff
            }
        }
        
        // Move pointer forward
        lastKeystrokeTime = now
        
        DispatchQueue.main.async { [weak self] in
            self?.statsStore.recordKeystroke(elapsedSeconds: elapsed)
        }
    }
    
    private func openAccessibilitySettings() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
