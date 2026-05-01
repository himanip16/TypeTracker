import SwiftUI

// This is the entry point of the app.
// When the app starts, execution begins from here.
@main
struct TypeTrackerApp: App {
    
    // This line connects our SwiftUI app to the older AppKit-style system.
    // Normally, SwiftUI apps don’t use AppDelegate, but here we explicitly say:
    // "Use MenuBarManager as the central controller for app behavior."
    //
    // So behind the scenes:
    // 1. The system creates an instance of MenuBarManager
    // 2. It calls its lifecycle functions (like applicationDidFinishLaunching)
    // 3. That is where our menu bar icon and monitoring setup happens
    @NSApplicationDelegateAdaptor(MenuBarManager.self) var appDelegate
    
    // This defines what "windows" or "screens" the app provides.
    var body: some Scene {
        
        // A "Settings" scene normally creates a settings/preferences window.
        // But here, we intentionally keep it empty.
        //
        // Why?
        // Because this app is only meant to live in the menu bar.
        // We don’t want a normal window popping up when the app launches.
        Settings {
            EmptyView()
        }
    }
}
