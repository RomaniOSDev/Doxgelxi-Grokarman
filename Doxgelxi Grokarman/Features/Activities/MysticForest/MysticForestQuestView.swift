//
//  MysticForestQuestView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct MysticForestQuestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: QuestStore

    let level: Int
    let difficulty: QuestStore.Difficulty

    @StateObject private var vm = MysticForestQuestViewModel()
    @State private var result: ActivityResult?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                GeometryReader { geo in
                    ZStack {
                        ForestBoard(level: level, obstacles: vm.obstacles, runes: vm.runes, player: vm.player)
                            .padding(18)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        vm.startIfNeeded()
                                        let local = value.location
                                        let inset: CGFloat = 18
                                        let board = CGRect(x: inset, y: inset, width: geo.size.width - inset * 2, height: geo.size.height - inset * 2)
                                        let nx = (local.x - board.minX) / max(1, board.width)
                                        let ny = (local.y - board.minY) / max(1, board.height)
                                        vm.updatePlayer(to: CGPoint(x: nx, y: ny))
                                    }
                            )
                    }
                }
                .frame(height: 420)
                .appPlayfieldPanel(cornerRadius: 22)
                .padding(.horizontal, 16)

                footer
            }
            .padding(.bottom, 20)
        }
        .scrollDisabled(true)
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $result) { res in
            ResultView(
                result: res,
                onRetry: { retry() },
                onNext: { goNext(from: res) },
                onBackToLevels: {
                    result = nil
                    dismiss()
                }
            )
        }
        .onAppear {
            store.markActivitySeen(.mysticForest)
            vm.configure(level: level, difficulty: difficulty)
        }
        .onChange(of: vm.phase) { _, phase in
            switch phase {
            case .completed:
                finish(won: true, failureReason: nil)
            case .failed(let reason):
                finish(won: false, failureReason: reason)
            default:
                break
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mystic Forest Quest")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appTextPrimary, Color.appAccent.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.appPrimary.opacity(0.14), radius: 6, x: 0, y: 3)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack {
                Text("Level \(level)")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                if let t = vm.timeRemaining, difficulty == .hard {
                    Text("Time: \(max(0, t - vm.elapsedSeconds()))s")
                        .foregroundStyle(Color.appTextSecondary)
                } else {
                    Text("Hits: \(vm.hits)")
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            if case .failed(let reason) = vm.phase {
                Text(reason)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .appCardChrome(cornerRadius: 18, elevated: false)
                    .padding(.horizontal, 16)
            }

            HStack(spacing: 12) {
                Button {
                    retry()
                } label: {
                    Text("Restart")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(SecondaryButtonStyle())

                Button {
                    vm.startIfNeeded()
                } label: {
                    Text("Play")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!(vm.phase == .ready))
                .opacity(vm.phase == .ready ? 1 : 0.55)
            }
            .padding(.horizontal, 16)

            Text("Drag the orb, collect all runes, then reach the gate.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.horizontal, 16)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
    }

    private func retry() {
        result = nil
        vm.reset()
    }

    private func finish(won: Bool, failureReason: String?) {
        guard result == nil else { return }
        let elapsed = vm.elapsedSeconds()
        let beforeAchievements = store.achievementProgressSnapshot()

        store.addPlaySession(seconds: elapsed)
        store.recordActivityPlayed()

        let runeCount = vm.runes.filter(\.collected).count
        let baseStars = won ? 1 : 0
        let bonusRunes = won && runeCount == vm.runes.count ? 1 : 0
        let bonusClean = won && vm.hits == 0 ? 1 : 0
        let stars = min(3, baseStars + bonusRunes + bonusClean)

        let improved = store.setStars(stars, activity: .mysticForest, level: level)
        let unlockedNext = (level < store.levelsPerActivity) ? store.isLevelUnlocked(activity: .mysticForest, level: level + 1) : false
        let newAchievements = store.newlyUnlockedAchievementTitles(since: beforeAchievements)

        let lines: [String] = [
            "Runes collected: \(runeCount)/\(vm.runes.count)",
            won ? "Path cleared." : (failureReason ?? "Try again.")
        ]

        result = ActivityResult(
            activity: .mysticForest,
            level: level,
            difficulty: difficulty,
            stars: stars,
            elapsedSeconds: elapsed,
            detailLines: lines,
            unlockedNextLevel: unlockedNext,
            improvedBest: improved,
            newAchievementTitles: newAchievements
        )
    }

    private func goNext(from res: ActivityResult) {
        if level >= store.levelsPerActivity {
            result = nil
            dismiss()
            return
        }
        result = nil
        vm.configure(level: level + 1, difficulty: difficulty)
    }
}

private struct ForestBoard: View {
    let level: Int
    let obstacles: [MysticForestQuestViewModel.Obstacle]
    let runes: [MysticForestQuestViewModel.Rune]
    let player: CGPoint

    private var groveBackdrop: LinearGradient {
        let v = (level - 1) % 5
        let palettes: [[Color]] = [
            [Color.appBackground.opacity(0.88), Color.appSurface.opacity(0.42)],
            [Color.appSurface.opacity(0.48), Color.appBackground.opacity(0.86)],
            [Color.appPrimary.opacity(0.16), Color.appSurface.opacity(0.5)],
            [Color.appAccent.opacity(0.12), Color.appBackground.opacity(0.88)],
            [Color.appSurface.opacity(0.55), Color.appAccent.opacity(0.1)],
        ]
        let colors = palettes[v]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(groveBackdrop)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 8)

                ForEach(obstacles) { o in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(o.kindFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
                        )
                        .frame(width: o.rect.width * geo.size.width, height: o.rect.height * geo.size.height)
                        .position(x: (o.rect.midX) * geo.size.width, y: (o.rect.midY) * geo.size.height)
                        .shadow(color: Color.black.opacity(0.38), radius: 10, x: 0, y: 6)
                        .shadow(color: Color.appPrimary.opacity(o.kind.isMovingTrap ? 0.22 : 0), radius: 12, x: 0, y: 4)
                }

                ForEach(runes) { rune in
                    RuneView(collected: rune.collected)
                        .frame(width: 28, height: 28)
                        .position(x: rune.center.x * geo.size.width, y: rune.center.y * geo.size.height)
                        .opacity(rune.collected ? 0.25 : 1)
                        .animation(.easeInOut(duration: 0.18), value: rune.collected)
                }

                FinishGate()
                    .frame(width: 72, height: 56)
                    .position(x: 0.90 * geo.size.width, y: 0.10 * geo.size.height)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appAccent.opacity(0.95), Color.appPrimary],
                            center: .topLeading,
                            startRadius: 2,
                            endRadius: 26
                        )
                    )
                    .frame(width: 28, height: 28)
                    .overlay(Circle().stroke(Color.appTextPrimary.opacity(0.28), lineWidth: 2))
                    .shadow(color: Color.appPrimary.opacity(0.55), radius: 14, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
                    .position(x: player.x * geo.size.width, y: player.y * geo.size.height)
            }
        }
    }
}

private extension MysticForestQuestViewModel.Obstacle.Kind {
    var isMovingTrap: Bool {
        if case .movingTrap = self { return true }
        return false
    }
}

private extension MysticForestQuestViewModel.Obstacle {
    var kindFill: LinearGradient {
        switch kind {
        case .wall:
            return LinearGradient(
                colors: [Color.appSurface.opacity(0.95), Color.appBackground.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .movingTrap:
            return LinearGradient(
                colors: [Color.appAccent.opacity(0.95), Color.appPrimary.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct RuneView: View {
    let collected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appAccent.opacity(collected ? 0.25 : 0.35))
            Path { p in
                p.move(to: CGPoint(x: 0.50, y: 0.18))
                p.addLine(to: CGPoint(x: 0.80, y: 0.50))
                p.addLine(to: CGPoint(x: 0.50, y: 0.82))
                p.addLine(to: CGPoint(x: 0.20, y: 0.50))
                p.closeSubpath()
            }
            .fill(Color.appPrimary.opacity(collected ? 0.35 : 1))
        }
        .drawingGroup()
    }
}

private struct FinishGate: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppDecor.panelFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppDecor.panelStroke, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppDecor.panelInsetShine)
                        .blendMode(.plusLighter)
                )

            VStack(spacing: 6) {
                Image(systemName: "door.left.hand.open")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.appAccent)
                Text("Exit")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .shadow(color: Color.black.opacity(0.42), radius: 14, x: 0, y: 8)
        .shadow(color: Color.appAccent.opacity(0.18), radius: 18, x: 0, y: 10)
    }
}

