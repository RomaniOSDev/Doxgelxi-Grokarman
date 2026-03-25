//
//  AdventuresHomeView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct AdventuresHomeView: View {
    @EnvironmentObject private var store: QuestStore

    private var difficultyBinding: Binding<QuestStore.Difficulty> {
        Binding(
            get: { store.preferredDifficulty },
            set: { store.preferredDifficulty = $0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Adventures")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appTextPrimary, Color.appAccent.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.appPrimary.opacity(0.18), radius: 10, x: 0, y: 5)
                    .padding(.top, 8)

                DifficultyPickerView(selection: difficultyBinding)

                VStack(spacing: 12) {
                    ForEach(QuestStore.ActivityID.allCases) { activity in
                        NavigationLink {
                            LevelSelectView(activity: activity, difficulty: store.preferredDifficulty)
                        } label: {
                            ActivityCard(activity: activity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .appScreenBackground()
        .id(store.revision)
    }
}

private struct ActivityCard: View {
    @EnvironmentObject private var store: QuestStore
    let activity: QuestStore.ActivityID

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ActivityGlyphView(activity: activity)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(activity.subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.top, 6)
            }

            HStack {
                ProgressPill(title: "Unlocked", value: unlockedText)
                Spacer(minLength: 10)
                ProgressPill(title: "Stars", value: "\(activityStars)")
            }
        }
        .padding(16)
        .appCardChrome(cornerRadius: 18, elevated: true)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.title). \(unlockedText) levels unlocked. \(activityStars) stars earned.")
    }

    private var unlockedText: String {
        let firstLocked = store.firstLockedLevel(activity: activity) ?? (store.levelsPerActivity + 1)
        let unlocked = min(store.levelsPerActivity, max(1, firstLocked - 1))
        return "\(unlocked)/\(store.levelsPerActivity)"
    }

    private var activityStars: Int {
        (1...store.levelsPerActivity).reduce(0) { $0 + store.stars(activity: activity, level: $1) }
    }
}

private struct ProgressPill: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.appBackground.opacity(0.45))
        )
    }
}
