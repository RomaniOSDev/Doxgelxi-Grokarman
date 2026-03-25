//
//  MountainAscentView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct MountainAscentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: QuestStore

    let level: Int
    let difficulty: QuestStore.Difficulty

    @StateObject private var vm = MountainAscentViewModel()
    @State private var result: ActivityResult?
    /// Tracks finger down on the hold control (Button + LongPress breaks; use DragGesture instead).
    @State private var isHoldFingerDown: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                ZStack {
                    VStack(spacing: 16) {
                        ClimbIllustration(level: level, progress: progress, windOffset: vm.windOffset, showSlide: vm.showSlide)
                            .frame(height: 260)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        TensionMeter(tension: vm.tension, window: vm.currentTensionWindow)
                            .padding(.horizontal, 16)

                        holdButton
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
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
            store.markActivitySeen(.mountainAscent)
            vm.configure(level: level, difficulty: difficulty)
        }
        .onChange(of: vm.phase) { _, phase in
            if phase != .climbing {
                isHoldFingerDown = false
            }
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
            Text("Mountain Ascent")
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
                Text("Segments: \(min(vm.segmentsTotal, vm.segmentIndex + 1))/\(vm.segmentsTotal)")
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
                    Text("Begin")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!(vm.phase == .ready))
                .opacity(vm.phase == .ready ? 1 : 0.55)
            }
            .padding(.horizontal, 16)

            Text("Press and hold to build tension, then release inside the target zone.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.horizontal, 16)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
    }

    private var holdButton: some View {
        let canInteract = (vm.phase == .climbing)
        return HStack(spacing: 10) {
            Image(systemName: canInteract ? "hand.tap.fill" : "hand.tap")
            Text(canInteract ? (isHoldFingerDown ? "Holding..." : "Hold") : "Hold")
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .font(.system(size: 17, weight: .semibold, design: .rounded))
        .foregroundStyle(Color.appTextPrimary)
        .frame(maxWidth: .infinity, minHeight: 56)
        .background {
            if canInteract {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppDecor.primaryButtonFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.appTextPrimary.opacity(0.18), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppDecor.primaryButtonHighlight)
                            .blendMode(.plusLighter)
                    )
                    .shadow(color: Color.appPrimary.opacity(0.42), radius: 12, x: 0, y: 7)
                    .shadow(color: Color.black.opacity(0.28), radius: 6, x: 0, y: 3)
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appPrimary.opacity(0.35))
            }
        }
        .contentShape(Rectangle())
        .allowsHitTesting(canInteract)
        .opacity(canInteract ? 1 : 0.55)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard vm.phase == .climbing else { return }
                    if !isHoldFingerDown {
                        isHoldFingerDown = true
                        vm.beginHold()
                    }
                }
                .onEnded { _ in
                    guard isHoldFingerDown else { return }
                    isHoldFingerDown = false
                    vm.endHold()
                }
        )
        .accessibilityLabel("Hold")
    }

    private var progress: Double {
        guard vm.segmentsTotal > 0 else { return 0 }
        return min(1, max(0, Double(vm.segmentIndex) / Double(vm.segmentsTotal)))
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
        let efficiency = won ? (vm.attempts <= (difficulty == .easy ? 999 : (difficulty == .normal ? 6 : 5)) ? 1 : 0) : 0
        let speedBonus: Int = won && elapsed <= max(18, 34 - level) ? 1 : 0
        let stars = min(3, baseStars + efficiency + speedBonus)

        let improved = store.setStars(stars, activity: .mountainAscent, level: level)
        let unlockedNext = (level < store.levelsPerActivity) ? store.isLevelUnlocked(activity: .mountainAscent, level: level + 1) : false
        let newAchievements = store.newlyUnlockedAchievementTitles(since: beforeAchievements)

        let lines: [String] = [
            "Attempts: \(vm.attempts)",
            won ? "Summit reached." : (failureReason ?? "Try again.")
        ]

        result = ActivityResult(
            activity: .mountainAscent,
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

private struct TensionMeter: View {
    let tension: Double
    let window: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Rope tension")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(Int(tension * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appBackground.opacity(0.72), Color.appSurface.opacity(0.35)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.appTextPrimary.opacity(0.06), lineWidth: 1)
                        )

                    let w = geo.size.width
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.appAccent.opacity(0.35))
                        .frame(width: CGFloat(window.lowerBound) * w)

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.appPrimary.opacity(0.35))
                        .frame(width: CGFloat(window.upperBound - window.lowerBound) * w)
                        .offset(x: CGFloat(window.lowerBound) * w)

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appPrimary.opacity(0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(6, CGFloat(tension) * w))
                        .shadow(color: Color.appAccent.opacity(0.45), radius: 6, x: 0, y: 2)
                }
            }
            .frame(height: 18)
        }
        .padding(14)
        .appCardChrome(cornerRadius: 18, elevated: false)
    }
}

private struct ClimbIllustration: View {
    let level: Int
    let progress: Double
    let windOffset: Double
    let showSlide: Bool

    private var silhouette: Int { (level - 1) % 4 }

    private var backdrop: LinearGradient {
        let pairs: [(Color, Color)] = [
            (Color.appBackground.opacity(0.88), Color.appSurface.opacity(0.38)),
            (Color.appSurface.opacity(0.55), Color.appBackground.opacity(0.82)),
            (Color.appPrimary.opacity(0.22), Color.appSurface.opacity(0.45)),
            (Color.appAccent.opacity(0.14), Color.appBackground.opacity(0.9)),
        ]
        let p = pairs[silhouette]
        return LinearGradient(colors: [p.0, p.1], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(backdrop)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.22), radius: 10, x: 0, y: 6)

            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size).insetBy(dx: 18, dy: 18)

                var mountain = Path()
                switch silhouette {
                case 1:
                    mountain.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                    mountain.addLine(to: CGPoint(x: rect.midX - 22, y: rect.minY + 34))
                    mountain.addLine(to: CGPoint(x: rect.midX + 36, y: rect.minY + 18))
                    mountain.addLine(to: CGPoint(x: rect.maxX - 6, y: rect.maxY))
                    mountain.closeSubpath()
                case 2:
                    mountain.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                    mountain.addLine(to: CGPoint(x: rect.midX - 44, y: rect.minY + 48))
                    mountain.addLine(to: CGPoint(x: rect.midX - 6, y: rect.minY + 22))
                    mountain.addLine(to: CGPoint(x: rect.midX + 32, y: rect.minY + 40))
                    mountain.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                    mountain.closeSubpath()
                case 3:
                    mountain.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                    mountain.addLine(to: CGPoint(x: rect.midX - 8, y: rect.minY + 62))
                    mountain.addLine(to: CGPoint(x: rect.midX + 28, y: rect.minY + 28))
                    mountain.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                    mountain.closeSubpath()
                default:
                    mountain.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                    mountain.addLine(to: CGPoint(x: rect.midX - 30, y: rect.minY + 20))
                    mountain.addLine(to: CGPoint(x: rect.midX + 20, y: rect.minY + 54))
                    mountain.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                    mountain.closeSubpath()
                }
                context.fill(mountain, with: .color(.appSurface.opacity(0.85)))

                let ropeXFractions: [CGFloat] = [0.35, 0.42, 0.30, 0.38]
                let ropeX = rect.minX + rect.width * ropeXFractions[silhouette]
                let ropeTop = CGPoint(x: ropeX, y: rect.minY + 18)
                let ropeBottom = CGPoint(x: ropeX + windOffset, y: rect.maxY - 8)
                var rope = Path()
                rope.move(to: ropeTop)
                rope.addQuadCurve(to: ropeBottom, control: CGPoint(x: ropeX + windOffset * 0.6, y: rect.midY))
                context.stroke(rope, with: .color(.appAccent), lineWidth: 4)

                let climberY = ropeBottom.y - (rect.height * CGFloat(progress)) - 10
                let climber = Path(ellipseIn: CGRect(x: ropeX - 10, y: climberY - 10, width: 20, height: 20))
                context.fill(climber, with: .color(.appPrimary))
            }

            if showSlide {
                Text("Rock slide!")
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
                    .shadow(color: Color.appPrimary.opacity(0.5), radius: 12, x: 0, y: 6)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showSlide)
    }
}

