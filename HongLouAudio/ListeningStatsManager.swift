//
//  ListeningStatsManager.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation
import Combine

final class ListeningStatsManager: ObservableObject {
    static let shared = ListeningStatsManager()

    @Published var totalSeconds: TimeInterval = 0
    @Published var listeningDates: Set<String> = []
    @Published var completedChapterCount: Int = 0

    private let totalSecondsKey = "stats_totalSeconds"
    private let listeningDatesKey = "stats_listeningDates"
    private var lastTickDate: Date?

    private init() {
        load()
    }

    // MARK: - Recording

    /// Call this periodically during playback (e.g., every 30s)
    func recordTick() {
        let now = Date()

        // Deduplicate: only count one tick per 30 seconds
        if let last = lastTickDate, now.timeIntervalSince(last) < 25 {
            return
        }
        lastTickDate = now

        // Accumulate time (30 seconds per tick)
        totalSeconds += 30

        // Record today's date for streak
        let today = Self.dateString(from: now)
        listeningDates.insert(today)

        save()
    }

    // MARK: - Computed Properties

    var totalHours: Double {
        totalSeconds / 3600.0
    }

    var formattedTotalTime: String {
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        if hours > 0 {
            return "\(hours) 小时 \(minutes) 分钟"
        }
        return "\(minutes) 分钟"
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let today = Self.dateString(from: Date())

        // Must have listened today to continue streak
        guard listeningDates.contains(today) else { return 0 }

        var streak = 1
        var date = Date()
        while true {
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            let prevString = Self.dateString(from: previous)
            if listeningDates.contains(prevString) {
                streak += 1
                date = previous
            } else {
                break
            }
        }
        return streak
    }

    var totalListeningDays: Int {
        listeningDates.count
    }

    // MARK: - Update completed chapter count (called from ContentView)
    func updateCompletedCount(_ count: Int) {
        completedChapterCount = count
    }

    // MARK: - Persistence

    private func load() {
        let defaults = UserDefaults.standard
        totalSeconds = defaults.double(forKey: totalSecondsKey)
        if let dates = defaults.array(forKey: listeningDatesKey) as? [String] {
            listeningDates = Set(dates)
        }
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(totalSeconds, forKey: totalSecondsKey)
        defaults.set(Array(listeningDates), forKey: listeningDatesKey)
    }

    private static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
