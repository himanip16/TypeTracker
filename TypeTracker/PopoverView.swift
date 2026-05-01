import SwiftUI

struct PopoverView: View {
    
    @ObservedObject var statsStore: StatsStore
    
    // Extract today's stats safely
    var todayStats: DayStats {
        let today = getTodayKey()
        return statsStore.statsByDate[today] ?? DayStats(keys: 0, time: 0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            
            Text("TypeTracker")
                .font(.headline)
            
            Divider()
            
            // Show today's key count
            Text("\(todayStats.keys)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            
            Text("keys pressed today")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Reset Count") {
                resetToday()
            }
        }
        .padding()
        .frame(width: 200, height: 160)
    }
    
    // Reset only today's bucket instead of entire history
    private func resetToday() {
        let today = getTodayKey()
        statsStore.statsByDate[today] = DayStats(keys: 0, time: 0)
    }
}
