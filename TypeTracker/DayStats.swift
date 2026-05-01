import Foundation

struct DayStats: Codable {
    var keys: Int
    var time: TimeInterval // stored in seconds

    // Derived property: computed on the fly, never stored.
    var keysPerSecond: Double {
        guard time > 0 else { return 0 }
        return Double(keys) / time
    }
}

public func getTodayKey() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone.current
    return formatter.string(from: Date())
}
