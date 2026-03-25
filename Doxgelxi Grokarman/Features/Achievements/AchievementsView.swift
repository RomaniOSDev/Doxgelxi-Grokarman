//
//  AchievementsView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: QuestStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Achievements")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appTextPrimary, Color.appAccent.opacity(0.92)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.appPrimary.opacity(0.22), radius: 12, x: 0, y: 6)
                    .padding(.top, 8)

                VStack(spacing: 12) {
                    AchievementCard(
                        title: "First Stars",
                        subtitle: "Earn your first star.",
                        isUnlocked: store.hasAnyStars,
                        progress: store.hasAnyStars ? 1 : 0
                    )

                    AchievementCard(
                        title: "Trail Blazer",
                        subtitle: "Complete all levels in any adventure.",
                        isUnlocked: store.hasClearedAllLevelsInAnyActivity,
                        progress: progressAllLevelsInBestActivity()
                    )

                    AchievementCard(
                        title: "Perfect Explorer",
                        subtitle: "Earn 3 stars on every level in any adventure.",
                        isUnlocked: store.hasPerfectedAnyActivity,
                        progress: progressPerfectInBestActivity()
                    )

                    AchievementCard(
                        title: "Marathon",
                        subtitle: "Play for 30 minutes in total.",
                        isUnlocked: store.hasMarathonPlayTime,
                        progress: min(1, Double(store.totalPlaySeconds) / Double(30 * 60))
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .id(store.revision)
    }

    private func progressAllLevelsInBestActivity() -> Double {
        let totals = QuestStore.ActivityID.allCases.map { activity in
            (1...store.levelsPerActivity).filter { store.stars(activity: activity, level: $0) > 0 }.count
        }
        let best = totals.max() ?? 0
        return Double(best) / Double(store.levelsPerActivity)
    }

    private func progressPerfectInBestActivity() -> Double {
        let totals = QuestStore.ActivityID.allCases.map { activity in
            (1...store.levelsPerActivity).filter { store.stars(activity: activity, level: $0) == 3 }.count
        }
        let best = totals.max() ?? 0
        return Double(best) / Double(store.levelsPerActivity)
    }
}

private struct AchievementCard: View {
    let title: String
    let subtitle: String
    let isUnlocked: Bool
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(
                            isUnlocked
                                ? LinearGradient(
                                    colors: [Color.appPrimary.opacity(0.45), Color.appAccent.opacity(0.22)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.appBackground.opacity(0.65), Color.appSurface.opacity(0.35)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.appAccent.opacity(isUnlocked ? 0.62 : 0.18), lineWidth: 1)
                        )
                        .shadow(color: Color.appPrimary.opacity(isUnlocked ? 0.35 : 0), radius: 10, x: 0, y: 5)

                    Image(systemName: isUnlocked ? "checkmark.seal.fill" : "seal")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(isUnlocked ? Color.appAccent : Color.appTextSecondary)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 10)

                Text(isUnlocked ? "Unlocked" : "Locked")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(isUnlocked ? Color.appAccent : Color.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            ProgressView(value: min(1, max(0, progress)))
                .tint(Color.appAccent)
        }
        .padding(16)
        .appCardChrome(cornerRadius: 18, elevated: true)
        .accessibilityElement(children: .combine)
    }
}

