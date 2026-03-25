//
//  LevelSelectView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject private var store: QuestStore

    let activity: QuestStore.ActivityID
    let difficulty: QuestStore.Difficulty

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(activity.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appTextPrimary, Color.appAccent.opacity(0.88)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.appPrimary.opacity(0.16), radius: 8, x: 0, y: 4)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.top, 8)

                Text("Difficulty: \(difficulty.title)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(1...store.levelsPerActivity, id: \.self) { level in
                        let unlocked = store.isLevelUnlocked(activity: activity, level: level)

                        NavigationLink {
                            ActivityHostView(activity: activity, level: level, difficulty: difficulty)
                        } label: {
                            LevelCell(level: level, unlocked: unlocked, stars: store.stars(activity: activity, level: level))
                        }
                        .buttonStyle(.plain)
                        .disabled(!unlocked)
                        .opacity(unlocked ? 1 : 0.55)
                    }
                }
                .padding(.top, 6)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LevelCell: View {
    let level: Int
    let unlocked: Bool
    let stars: Int

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if unlocked {
                    Text("\(level)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
            .frame(height: 72)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appBackground.opacity(0.88),
                                Color.appSurface.opacity(0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.appTextPrimary.opacity(0.06), lineWidth: 1)
                    )
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < stars ? "star.fill" : "star")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(i < stars ? Color.appAccent : Color.appTextSecondary.opacity(0.55))
                }
            }
            .frame(height: 16)
        }
        .padding(10)
        .appCardChrome(cornerRadius: 18, elevated: false)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(unlocked ? "Level \(level), \(stars) stars" : "Locked level \(level)")
    }
}

