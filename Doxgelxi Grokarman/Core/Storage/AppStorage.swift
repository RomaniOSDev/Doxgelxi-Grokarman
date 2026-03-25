//
//  AppStorage.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import Foundation
import Combine

final class QuestStore: ObservableObject {
    static let shared = QuestStore()

    @Published private(set) var revision: Int = 0

    private let defaults: UserDefaults
    private let notificationName = Notification.Name("QuestStore.didResetAll")

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - App lifecycle flags

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasSeenOnboarding) }
        set {
            defaults.set(newValue, forKey: Keys.hasSeenOnboarding)
            bump()
        }
    }

    // MARK: - Progress

    let levelsPerActivity: Int = 12

    func stars(activity: ActivityID, level: Int) -> Int {
        let key = Keys.stars(activity: activity, level: level)
        let value = defaults.integer(forKey: key)
        return max(0, min(3, value))
    }

    func setStars(_ stars: Int, activity: ActivityID, level: Int) -> Bool {
        let clamped = max(0, min(3, stars))
        let key = Keys.stars(activity: activity, level: level)
        let previous = defaults.integer(forKey: key)
        guard clamped > previous else { return false }
        defaults.set(clamped, forKey: key)
        bump()
        return true
    }

    func isLevelUnlocked(activity: ActivityID, level: Int) -> Bool {
        if level <= 1 { return true }
        return stars(activity: activity, level: level - 1) > 0
    }

    func firstLockedLevel(activity: ActivityID) -> Int? {
        for level in 1...levelsPerActivity {
            if !isLevelUnlocked(activity: activity, level: level) {
                return level
            }
        }
        return nil
    }

    var totalStars: Int {
        ActivityID.allCases.reduce(0) { partial, activity in
            partial + (1...levelsPerActivity).reduce(0) { $0 + stars(activity: activity, level: $1) }
        }
    }

    var totalLevelSlots: Int {
        ActivityID.allCases.count * levelsPerActivity
    }

    /// Levels with at least one star earned (any activity).
    var clearedLevelSlotsCount: Int {
        ActivityID.allCases.reduce(0) { sum, activity in
            sum + (1...levelsPerActivity).filter { stars(activity: activity, level: $0) > 0 }.count
        }
    }

    /// Next unlocked level that is not yet perfected (for “Continue” on Home).
    func nextSuggestedChallenge() -> (activity: ActivityID, level: Int)? {
        for activity in ActivityID.allCases {
            for level in 1...levelsPerActivity {
                guard isLevelUnlocked(activity: activity, level: level) else { continue }
                if stars(activity: activity, level: level) < 3 {
                    return (activity, level)
                }
            }
        }
        return nil
    }

    var preferredDifficulty: Difficulty {
        get {
            let raw = defaults.string(forKey: Keys.preferredDifficulty) ?? Difficulty.easy.rawValue
            return Difficulty(rawValue: raw) ?? .easy
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.preferredDifficulty)
            bump()
        }
    }

    // MARK: - Stats

    var totalPlaySeconds: Int {
        max(0, defaults.integer(forKey: Keys.totalPlaySeconds))
    }

    var activitiesPlayedCount: Int {
        max(0, defaults.integer(forKey: Keys.activitiesPlayed))
    }

    func addPlaySession(seconds: Int) {
        guard seconds > 0 else { return }
        let next = totalPlaySeconds + seconds
        defaults.set(next, forKey: Keys.totalPlaySeconds)
        bump()
    }

    func recordActivityPlayed() {
        defaults.set(activitiesPlayedCount + 1, forKey: Keys.activitiesPlayed)
        bump()
    }

    // MARK: - Achievements (computed)

    var hasAnyStars: Bool { totalStars > 0 }

    var hasPlayedAllActivities: Bool {
        let played = Set((defaults.array(forKey: Keys.activitiesPlayedSet) as? [String]) ?? [])
        return ActivityID.allCases.allSatisfy { played.contains($0.rawValue) }
    }

    func markActivitySeen(_ activity: ActivityID) {
        var played = Set((defaults.array(forKey: Keys.activitiesPlayedSet) as? [String]) ?? [])
        played.insert(activity.rawValue)
        defaults.set(Array(played), forKey: Keys.activitiesPlayedSet)
        bump()
    }

    var hasClearedAllLevelsInAnyActivity: Bool {
        ActivityID.allCases.contains { activity in
            (1...levelsPerActivity).allSatisfy { stars(activity: activity, level: $0) > 0 }
        }
    }

    var hasPerfectedAnyActivity: Bool {
        ActivityID.allCases.contains { activity in
            (1...levelsPerActivity).allSatisfy { stars(activity: activity, level: $0) == 3 }
        }
    }

    var hasMarathonPlayTime: Bool {
        totalPlaySeconds >= 30 * 60
    }

    struct AchievementProgressSnapshot: Equatable {
        let hasAnyStar: Bool
        let clearedAllInSomeActivity: Bool
        let perfectedSomeActivity: Bool
        let marathonTime: Bool
    }

    func achievementProgressSnapshot() -> AchievementProgressSnapshot {
        AchievementProgressSnapshot(
            hasAnyStar: hasAnyStars,
            clearedAllInSomeActivity: hasClearedAllLevelsInAnyActivity,
            perfectedSomeActivity: hasPerfectedAnyActivity,
            marathonTime: hasMarathonPlayTime
        )
    }

    /// Titles match the Achievements screen cards (for result banner copy).
    func newlyUnlockedAchievementTitles(since previous: AchievementProgressSnapshot) -> [String] {
        let now = achievementProgressSnapshot()
        var titles: [String] = []
        if !previous.hasAnyStar && now.hasAnyStar { titles.append("First Stars") }
        if !previous.clearedAllInSomeActivity && now.clearedAllInSomeActivity { titles.append("Trail Blazer") }
        if !previous.perfectedSomeActivity && now.perfectedSomeActivity { titles.append("Perfect Explorer") }
        if !previous.marathonTime && now.marathonTime { titles.append("Marathon") }
        return titles
    }

    // MARK: - Reset

    func resetAll() {
        let keysToRemove: [String] = [
            Keys.hasSeenOnboarding,
            Keys.totalPlaySeconds,
            Keys.activitiesPlayed,
            Keys.activitiesPlayedSet
        ] + ActivityID.allCases.flatMap { activity in
            (1...levelsPerActivity).map { Keys.stars(activity: activity, level: $0) }
        }

        keysToRemove.forEach { defaults.removeObject(forKey: $0) }
        bump()
        NotificationCenter.default.post(name: notificationName, object: nil)
    }

    // MARK: - Helpers

    private func bump() {
        revision &+= 1
    }

    enum ActivityID: String, CaseIterable, Identifiable {
        case mysticForest
        case mountainAscent
        case ruinsOfTime

        var id: String { rawValue }

        var title: String {
            switch self {
            case .mysticForest: return "Mystic Forest Quest"
            case .mountainAscent: return "Mountain Ascent"
            case .ruinsOfTime: return "Ruins of Time"
            }
        }

        var subtitle: String {
            switch self {
            case .mysticForest: return "Navigate winding paths and collect runes."
            case .mountainAscent: return "Hold steady to secure ropes and climb."
            case .ruinsOfTime: return "Rotate relics to align ancient symbols."
            }
        }
    }

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy
        case normal
        case hard

        var id: String { rawValue }

        var title: String {
            switch self {
            case .easy: return "Easy"
            case .normal: return "Normal"
            case .hard: return "Hard"
            }
        }
    }

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalPlaySeconds = "totalPlaySeconds"
        static let activitiesPlayed = "activitiesPlayedCount"
        static let activitiesPlayedSet = "activitiesPlayedSet"
        static let preferredDifficulty = "preferredDifficulty"

        static func stars(activity: ActivityID, level: Int) -> String {
            "stars.\(activity.rawValue).level.\(level)"
        }
    }
}

