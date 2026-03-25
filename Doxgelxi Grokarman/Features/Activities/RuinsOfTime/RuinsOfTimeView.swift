//
//  RuinsOfTimeView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct RuinsOfTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: QuestStore

    let level: Int
    let difficulty: QuestStore.Difficulty

    @StateObject private var vm = RuinsOfTimeViewModel()
    @State private var result: ActivityResult?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                ZStack {
                    VStack(spacing: 14) {
                        RelicPuzzleView(
                            level: level,
                            angles: vm.ringAngles,
                            targets: vm.targets,
                            difficulty: difficulty,
                            trapHintVisible: vm.trapHintVisible,
                            onRotateDelta: { index, delta in
                                vm.startIfNeeded()
                                vm.applyRingRotationDelta(index, deltaDegrees: delta)
                            },
                            onRotationGestureCommitted: { totalDegrees in
                                vm.registerRotationGestureEnded(totalMovementDegrees: totalDegrees)
                            }
                        )
                        .frame(height: 320)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        if difficulty != .easy, let left = vm.rotationsLeft {
                            HStack {
                                Text("Rotations left")
                                    .foregroundStyle(Color.appTextSecondary)
                                Spacer()
                                Text("\(max(0, left))")
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 16)
                        }

                        if difficulty == .hard {
                            Button {
                                vm.toggleHint()
                            } label: {
                                Text("Interact with traps")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        } else {
                            Spacer(minLength: 16)
                        }
                    }
                }
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
            store.markActivitySeen(.ruinsOfTime)
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
            Text("Ruins of Time")
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
                Text("Align all rings")
                    .foregroundStyle(Color.appTextSecondary)
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
                    Text("Solve")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!(vm.phase == .ready))
                .opacity(vm.phase == .ready ? 1 : 0.55)
            }
            .padding(.horizontal, 16)

            Text("Choose a ring below, then drag in circles over the puzzle to rotate it.")
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

        let baseStars = won ? 1 : 0
        let remainingBonus: Int = {
            guard won else { return 0 }
            guard let left = vm.rotationsLeft else { return 1 } // easy: always count as efficient
            return left >= 2 ? 1 : 0
        }()
        let speedBonus: Int = won && elapsed <= max(12, 26 - level) ? 1 : 0
        let stars = min(3, baseStars + remainingBonus + speedBonus)

        let improved = store.setStars(stars, activity: .ruinsOfTime, level: level)
        let unlockedNext = (level < store.levelsPerActivity) ? store.isLevelUnlocked(activity: .ruinsOfTime, level: level + 1) : false
        let newAchievements = store.newlyUnlockedAchievementTitles(since: beforeAchievements)

        let lines: [String] = [
            (vm.rotationsLeft == nil ? "No rotation limit." : "Rotations left: \(max(0, vm.rotationsLeft ?? 0))"),
            won ? "Door unlocked." : (failureReason ?? "Try again.")
        ]

        result = ActivityResult(
            activity: .ruinsOfTime,
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

private struct RelicPuzzleView: View {
    let level: Int
    let angles: [Double]
    let targets: [Double]
    let difficulty: QuestStore.Difficulty
    let trapHintVisible: Bool
    let onRotateDelta: (_ ringIndex: Int, _ deltaDegrees: Double) -> Void
    let onRotationGestureCommitted: (_ totalMovementDegrees: Double) -> Void

    @State private var activeRing: Int = 0
    @State private var lastDragAngleDegrees: Double?
    @State private var gestureTotalMovement: Double = 0

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appBackground.opacity(0.9), Color.appSurface.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.14), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 8)

                // One-finger orbit around puzzle center (RotationGesture needs two fingers on iOS).
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let deg = angleDegrees(from: center, to: value.location)
                                if let last = lastDragAngleDegrees {
                                    var delta = deg - last
                                    while delta > 180 { delta -= 360 }
                                    while delta < -180 { delta += 360 }
                                    if abs(delta) > 0.03 {
                                        gestureTotalMovement += abs(delta)
                                        onRotateDelta(activeRing, delta)
                                    }
                                }
                                lastDragAngleDegrees = deg
                            }
                            .onEnded { _ in
                                lastDragAngleDegrees = nil
                                onRotationGestureCommitted(gestureTotalMovement)
                                gestureTotalMovement = 0
                            }
                    )

                ForEach(0..<3, id: \.self) { i in
                    let ringSize = side * (0.82 - CGFloat(i) * 0.18)
                    RingView(
                        level: level,
                        ringIndex: i,
                        angle: angles[safe: i] ?? 0,
                        target: targets[safe: i] ?? 0,
                        isActive: activeRing == i,
                        difficulty: difficulty
                    )
                    .frame(width: ringSize, height: ringSize)
                    .position(center)
                    .allowsHitTesting(false)
                }

                if trapHintVisible {
                    Text("Trap triggered!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background {
                            Capsule(style: .continuous)
                                .fill(AppDecor.primaryButtonFill)
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color.appTextPrimary.opacity(0.15), lineWidth: 1)
                                )
                        }
                        .shadow(color: Color.appPrimary.opacity(0.48), radius: 14, x: 0, y: 7)
                        .transition(.opacity)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 8) {
                    Text("Selected ring")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { i in
                            Button {
                                withAnimation(.easeInOut(duration: 0.18)) { activeRing = i }
                            } label: {
                                Text("\(i + 1)")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .foregroundStyle(activeRing == i ? Color.appTextPrimary : Color.appTextSecondary)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(
                                                activeRing == i
                                                    ? LinearGradient(
                                                        colors: [Color.appPrimary.opacity(0.45), Color.appAccent.opacity(0.22)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                    : LinearGradient(
                                                        colors: [Color.appSurface.opacity(0.55), Color.appBackground.opacity(0.35)],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(Color.appAccent.opacity(activeRing == i ? 0.5 : 0.15), lineWidth: 1)
                                            )
                                    }
                                    .shadow(color: Color.black.opacity(activeRing == i ? 0.25 : 0.12), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Select ring \(i + 1)")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: trapHintVisible)
    }

    private func angleDegrees(from center: CGPoint, to point: CGPoint) -> Double {
        Double(atan2(point.y - center.y, point.x - center.x) * 180 / .pi)
    }
}

private struct RingView: View {
    let level: Int
    let ringIndex: Int
    let angle: Double
    let target: Double
    let isActive: Bool
    let difficulty: QuestStore.Difficulty

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appAccent.opacity(isActive ? 0.75 : 0.25), lineWidth: isActive ? 10 : 8)
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)

            Circle()
                .stroke(
                    Color.appSurface.opacity(0.9),
                    style: StrokeStyle(
                        lineWidth: 2,
                        dash: [CGFloat(5 + (level + ringIndex) % 5), 6 + CGFloat(level % 3)]
                    )
                )

            // Target mark (not shown on hard to keep it secret-ish).
            if difficulty != .hard {
                TargetMark()
                    .stroke(Color.appPrimary.opacity(0.85), lineWidth: 4)
                    .rotationEffect(.degrees(target))
                    .padding(10)
            }

            // Glyph group
            GlyphGroup()
                .fill(isActive ? Color.appPrimary : Color.appTextPrimary.opacity(0.75))
                .rotationEffect(.degrees(angle))
                .padding(22)
        }
        .contentShape(Circle())
    }
}

private struct GlyphGroup: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) * 0.38

        var path = Path()
        for i in 0..<6 {
            let a = (Double(i) / 6.0) * Double.pi * 2
            let x = c.x + CGFloat(cos(a)) * r
            let y = c.y + CGFloat(sin(a)) * r
            path.addEllipse(in: CGRect(x: x - 6, y: y - 6, width: 12, height: 12))
        }
        path.addEllipse(in: CGRect(x: c.x - 8, y: c.y - 8, width: 16, height: 16))
        return path
    }
}

private struct TargetMark: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY + 6))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.minY + 28))
        return p
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

