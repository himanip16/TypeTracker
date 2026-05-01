import Foundation
import Combine

// This class is like a small box that holds one number: total keys pressed.
// It also takes care of saving and loading that number.
class StatsStore: ObservableObject {
    
    // This special wrapper means:
    // "Whenever this value changes, tell the UI to refresh automatically."
    //
    // Think of it like a live wire:
    // value changes → signal sent → UI redraws with new number
    @Published var keystrokeCount: Int = 0
    
    // This is just a label used to store the value in the system.
    // Like writing a name on a drawer so you can find it later.
    private let key = "totalKeystrokes"
    
    init() {
        // When the app starts:
        // Ask the system: "Do you already have a saved number for this key?"
        //
        // If yes → load it
        // If no → system returns 0 by default
        self.keystrokeCount = UserDefaults.standard.integer(forKey: key)
    }
    
    func increment() {
        // Increase the count by 1
        keystrokeCount += 1
        
        // Immediately save the new value to the system.
        // So even if app closes, the number is not lost.
        UserDefaults.standard.set(keystrokeCount, forKey: key)
    }
    
    func reset() {
        // Set the count back to 0
        keystrokeCount = 0
        
        // Also overwrite the saved value with 0
        UserDefaults.standard.set(0, forKey: key)
    }
}
