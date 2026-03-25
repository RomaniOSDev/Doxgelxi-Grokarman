//
//  ActivityHostView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct ActivityHostView: View {
    let activity: QuestStore.ActivityID
    let level: Int
    let difficulty: QuestStore.Difficulty

    var body: some View {
        switch activity {
        case .mysticForest:
            MysticForestQuestView(level: level, difficulty: difficulty)
        case .mountainAscent:
            MountainAscentView(level: level, difficulty: difficulty)
        case .ruinsOfTime:
            RuinsOfTimeView(level: level, difficulty: difficulty)
        }
    }
}

