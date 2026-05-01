import Foundation
import AppKit

// This class is responsible for "listening" to keyboard activity happening anywhere on the system.
// It does NOT own the data — it just detects key presses and tells StatsStore to update.
class KeystrokeMonitor {
    
    // This holds the system-level listener.
    // If this is nil → nothing is being listened to.
    private var eventMonitor: Any?
    
    // Reference to the place where we store the count.
    private let statsStore: StatsStore
    
    init(statsStore: StatsStore) {
        self.statsStore = statsStore
    }
    
    /// This function asks macOS:
    /// "Am I allowed to observe keyboard activity happening in other apps?"
    ///
    /// macOS protects this very strictly.
    /// Without permission, key events never reach your app at all.
    func hasAccessibilityPermission() -> Bool {
        
        // This option does two things at once:
        // 1. Checks if permission already exists
        // 2. If not, shows a system popup asking the user
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        
        // System returns true → allowed
        // System returns false → blocked
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    /// This starts the actual listening process
    func startMonitoring() {
        
        // If we already started once, do nothing.
        // This prevents multiple listeners from stacking up.
        guard eventMonitor == nil else { return }
        
        // Step 1: Check permission
        if hasAccessibilityPermission() {
            
            // Step 2: Register a global listener
            //
            // "global" means:
            // Even if user is typing in Chrome, VSCode, Notes — we still receive the event.
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] _ in
                
                // This block runs every time ANY key is pressed anywhere
                
                // We jump to main thread before touching shared state
                DispatchQueue.main.async {
                    
                    // Increase count by 1
                    self?.statsStore.increment()
                }
            }
            
        } else {
            // If permission is missing:
            // - We cannot listen to anything
            // - eventMonitor remains nil
            // - No key presses will ever reach here
            
            print("TypeTracker: Waiting for accessibility permissions...")
            
            // Open system settings directly so user doesn't have to search manually
            openAccessibilitySettings()
        }
    }
    
    /// This opens the exact settings screen where user must allow access
    private func openAccessibilitySettings() {
        
        // This special URL is understood by macOS.
        // When opened, it jumps directly to:
        // System Settings → Privacy & Security → Accessibility
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    /// Stops listening to key events
    func stopMonitoring() {
        
        // If a listener exists, remove it from the system
        if let monitor = eventMonitor {
            
            // Tell macOS: "Stop sending me key events"
            NSEvent.removeMonitor(monitor)
            
            // Clear reference → now we know we are no longer listening
            eventMonitor = nil
        }
    }
}
