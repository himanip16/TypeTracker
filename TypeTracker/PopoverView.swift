import SwiftUI

// This defines the layout of the popup window.
struct PopoverView: View {
    
    // This connects the UI to the data store.
    //
    // Meaning:
    // UI reads keystrokeCount from here,
    // and automatically updates when it changes.
    @ObservedObject var statsStore: StatsStore
    
    var body: some View {
        
        // Stack items vertically, one below another
        VStack(spacing: 12) {
            
            // Title at the top
            Text("TypeTracker")
                .font(.headline)
            
            // A thin line separating title and content
            Divider()
            
            // The big number (total keys pressed)
            //
            // "\(value)" converts number → text
            Text("\(statsStore.keystrokeCount)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            
            // Small label explaining what the number means
            Text("keys pressed today")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Button at the bottom
            Button("Reset Count") {
                
                // When clicked:
                // 1. reset() sets count = 0
                // 2. @Published sends update signal
                // 3. UI redraws instantly → shows 0
                statsStore.reset()
            }
        }
        
        // Space inside the popup so content doesn't touch edges
        .padding()
        
        // Fixed size of the popup window
        .frame(width: 200, height: 160)
    }
}
