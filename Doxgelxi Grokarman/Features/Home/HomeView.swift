//
//  HomeView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: QuestStore
    @State private var heroAnimate: Bool = false

    private var difficultyBinding: Binding<QuestStore.Difficulty> {
        Binding(
            get: { store.preferredDifficulty },
            set: { store.preferredDifficulty = $0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HomeHeroCard(animate: heroAnimate)
                    .padding(.top, 8)
                    .onAppear {
                        heroAnimate = false
                        withAnimation(.spring(response: 0.9, dampingFraction: 0.72)) {
                            heroAnimate = true
                        }
                    }

                HomeStatsRow(
                    totalStars: store.totalStars,
                    clearedLevels: store.clearedLevelSlotsCount,
                    totalSlots: store.totalLevelSlots,
                    playSeconds: store.totalPlaySeconds
                )

                DifficultyPickerView(selection: difficultyBinding)

                continueSection

                VStack(alignment: .leading, spacing: 10) {
                    Text("Adventures")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("Pick a route. Your difficulty choice applies to every activity.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }

                VStack(spacing: 12) {
                    ForEach(QuestStore.ActivityID.allCases) { activity in
                        NavigationLink {
                            LevelSelectView(activity: activity, difficulty: store.preferredDifficulty)
                        } label: {
                            HomeAdventureRow(activity: activity)
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink {
                    AdventuresHomeView()
                } label: {
                    HStack {
                        Text("Detailed progress view")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 18)
                    .appCardChrome(cornerRadius: 16, elevated: true)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open detailed progress view")

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .id(store.revision)
    }

    @ViewBuilder
    private var continueSection: some View {
        if let next = store.nextSuggestedChallenge() {
            VStack(alignment: .leading, spacing: 10) {
                Text("Continue")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                NavigationLink {
                    ActivityHostView(activity: next.activity, level: next.level, difficulty: store.preferredDifficulty)
                } label: {
                    HomeContinueCard(activity: next.activity, level: next.level, difficulty: store.preferredDifficulty)
                }
                .buttonStyle(.plain)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Master explorer")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)

                Text("Every trail is perfected. Replay any level to refine your rhythm.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)

                NavigationLink {
                    LevelSelectView(activity: QuestStore.ActivityID.mysticForest, difficulty: store.preferredDifficulty)
                } label: {
                    Text("Replay Mystic Forest Quest")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}

// MARK: - Hero

private struct HomeHeroCard: View {
    let animate: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppDecor.panelFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AppDecor.panelStroke, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.15), Color.clear, Color.appAccent.opacity(0.08)],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                        .blendMode(.plusLighter)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(AppDecor.panelInsetShine)
                        .blendMode(.plusLighter)
                )

            HomeHeroIllustration(animate: animate)
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 6) {
                Text("Your journey")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text("Brave worlds, earn stars, unlock new chapters.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .padding(20)
        }
        .frame(minHeight: 260)
        .shadow(color: Color.black.opacity(0.45), radius: 28, x: 0, y: 18)
        .shadow(color: Color.appPrimary.opacity(0.15), radius: 36, x: 0, y: 22)
    }
}

private struct HomeHeroIllustration: View {
    let animate: Bool

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let center = CGPoint(x: w * 0.5, y: h * 0.42)

            var arc = Path()
            arc.addArc(center: center, radius: w * 0.28, startAngle: .degrees(210), endAngle: .degrees(-30), clockwise: true)
            context.stroke(arc, with: .color(.appAccent.opacity(0.55)), lineWidth: 4)

            var inner = Path()
            inner.addArc(center: center, radius: w * 0.16, startAngle: .degrees(animate ? 200 : 230), endAngle: .degrees(40), clockwise: false)
            context.stroke(inner, with: .color(.appPrimary.opacity(0.75)), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 10]))

            let peak = CGPoint(x: w * 0.72, y: h * 0.38)
            var torch = Path()
            torch.move(to: CGPoint(x: peak.x, y: peak.y + 24))
            torch.addLine(to: peak)
            context.stroke(torch, with: .color(.appAccent.opacity(0.9)), lineWidth: 5)
            context.fill(
                Path(ellipseIn: CGRect(x: peak.x - 8, y: peak.y - 18, width: 16, height: 20)),
                with: .color(.appPrimary.opacity(0.95))
            )
        }
        .drawingGroup()
    }
}

// MARK: - Stats

private struct HomeStatsRow: View {
    let totalStars: Int
    let clearedLevels: Int
    let totalSlots: Int
    let playSeconds: Int

    var body: some View {
        HStack(spacing: 10) {
            HomeStatTile(title: "Stars", value: "\(totalStars)", caption: "collected")
            HomeStatTile(title: "Paths", value: "\(clearedLevels)/\(totalSlots)", caption: "cleared")
            HomeStatTile(title: "Time", value: shortPlayTime(playSeconds), caption: "total")
        }
    }

    private func shortPlayTime(_ seconds: Int) -> String {
        let s = max(0, seconds)
        let h = s / 3600
        let m = (s % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m" }
        return "\(s)s"
    }
}

private struct HomeStatTile: View {
    let title: String
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(caption)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appAccent.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .appCardChrome(cornerRadius: 16, elevated: false)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Continue + rows

private struct HomeContinueCard: View {
    @EnvironmentObject private var store: QuestStore
    let activity: QuestStore.ActivityID
    let level: Int
    let difficulty: QuestStore.Difficulty

    var body: some View {
        HStack(spacing: 14) {
            ActivityGlyphView(activity: activity)
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(level)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appAccent)
                Text(activity.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                HStack(spacing: 8) {
                    Text(difficulty.title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                    starDots(for: store.stars(activity: activity, level: level))
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "play.circle.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(Color.appPrimary)
                .frame(minWidth: 44, minHeight: 44)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.28),
                            Color.appPrimary.opacity(0.10),
                            Color.appAccent.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appAccent.opacity(0.55), Color.appPrimary.opacity(0.35)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(AppDecor.panelInsetShine)
                        .blendMode(.plusLighter)
                )
        }
        .shadow(color: Color.appPrimary.opacity(0.32), radius: 22, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 8)
    }

    private func starDots(for count: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(i < count ? Color.appAccent : Color.appTextSecondary.opacity(0.35))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

private struct HomeAdventureRow: View {
    @EnvironmentObject private var store: QuestStore
    let activity: QuestStore.ActivityID

    var body: some View {
        HStack(spacing: 14) {
            ActivityGlyphView(activity: activity)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(activity.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(activityStars) stars")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appAccent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(minHeight: 44)
        }
        .padding(16)
        .appCardChrome(cornerRadius: 18, elevated: true)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var activityStars: Int {
        (1...store.levelsPerActivity).reduce(0) { $0 + store.stars(activity: activity, level: $1) }
    }
}
