import SwiftUI

// This class sets up the menu bar icon, the popup, and starts the key tracking.
class MenuBarManager: NSObject, NSApplicationDelegate {
    
    // This will hold the small icon in the top menu bar.
    // Without this, nothing appears on screen.
    var statusItem: NSStatusItem?
    
    // This is the popup window that appears when you click the icon.
    var popover: NSPopover?
    
    // This stores the number of keys pressed.
    let statsStore = StatsStore()
    
    // This listens to keyboard activity and updates statsStore.
    // "lazy" means it is created only when first used, not immediately.
    lazy var keystrokeMonitor = KeystrokeMonitor(statsStore: statsStore)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // Create a slot in the menu bar.
        // The system decides how wide it should be.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Get the clickable button inside that slot.
        if let button = statusItem?.button {
            
            // Show a keyboard icon.
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "TypeTracker")
            
            // When user clicks → call togglePopover
            button.action = #selector(togglePopover(_:))
            
            // Tell system this object will handle that action
            button.target = self
        }
        
        // Delay the rest slightly.
        // Internally, the UI system is still settling.
        // If we attach everything immediately, it can cause layout conflicts.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Create popup container
            let popover = NSPopover()
            
            // Auto-close when user clicks outside
            popover.behavior = .transient
            
            // Build the UI that goes inside popup
            let rootView = PopoverView(statsStore: self.statsStore)
                .frame(width: 200, height: 160)
            
            // Bridge SwiftUI view into older system
            popover.contentViewController = NSHostingController(rootView: rootView)
            
            // Keep reference so we can show/hide later
            self.popover = popover
            
            // Start listening to keyboard events
            self.keystrokeMonitor.startMonitoring()
        }
    }
    
    // Runs when user clicks the menu bar icon
    @objc func togglePopover(_ sender: AnyObject?) {
        
        // Get the icon button
        guard let button = statusItem?.button else { return }
        
        if let popover = popover {
            
            // If already open → close it
            if popover.isShown {
                popover.performClose(sender)
                
            } else {
                // If closed → show it just below the icon
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                
                // Bring it to front so it receives clicks/keyboard input
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}
