//
//  ActivityResult.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import Foundation

struct ActivityResult: Hashable, Identifiable {
    let id = UUID()
    let activity: QuestStore.ActivityID
    let level: Int
    let difficulty: QuestStore.Difficulty
    let stars: Int
    let elapsedSeconds: Int
    let detailLines: [String]
    let unlockedNextLevel: Bool
    let improvedBest: Bool
    let newAchievementTitles: [String]
}

