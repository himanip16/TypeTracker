import Foundation
import Combine

class StatsStore: ObservableObject {
    // In-memory cache for immediate UI responsiveness
    @Published var statsByDate: [String: DayStats] = [:]
    
    private let storageKey = "analytics_stats_by_date"
    private var lastKeyDate: String = ""
    
    // For debouncing disk I/O
    private var saveCancellable: AnyCancellable?
    private let savePublisher = PassthroughSubject<Void, Never>()
    
    // 1. Reuse DateFormatter forever
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    init() {
        loadFromDefaults()
        lastKeyDate = getTodayKey()
        
        // 3. Debounce saves: waits for 2 seconds of silence before writing to disk
        saveCancellable = savePublisher
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.saveToDefaults()
            }
    }
    
    /// Returns today's stable string key
    private func getTodayKey() -> String {
        return Self.dateFormatter.string(from: Date())
    }
    
    /// Called on every key press event
    func recordKeystroke(elapsedSeconds: TimeInterval) {
        let today = getTodayKey()
        
        // 4. Reset elapsed time if we cross the midnight boundary
        let adjustedElapsed = (today != lastKeyDate) ? 0 : elapsedSeconds
        lastKeyDate = today
        
        // 2. Explicitly extract, modify, and re-assign for clear mutation signaling
        var currentStats = statsByDate[today] ?? DayStats(keys: 0, time: 0)
        
        currentStats.keys += 1
        currentStats.time += adjustedElapsed
        
        // Re-assigning triggers the @Published publisher cleanly
        statsByDate[today] = currentStats
        
        // Trigger the debouncer for disk saving
        savePublisher.send()
    }
    
    // MARK: - Persistence
    
    private func saveToDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(statsByDate)
            UserDefaults.standard.set(data, forKey: storageKey)
            print("💾 Stats successfully persisted to disk.")
        } catch {
            print("❌ Failed to encode stats: \(error)")
        }
    }
    
    private func loadFromDefaults() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            self.statsByDate = [:]
            return
        }
        
        do {
            let decoder = JSONDecoder()
            self.statsByDate = try decoder.decode([String: DayStats].self, from: data)
        } catch {
            print("❌ Failed to decode stats: \(error)")
            self.statsByDate = [:]
        }
    }
}
