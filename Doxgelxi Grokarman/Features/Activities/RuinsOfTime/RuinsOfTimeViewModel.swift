//
//  RuinsOfTimeViewModel.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import Foundation
import Combine

@MainActor
final class RuinsOfTimeViewModel: ObservableObject {
    enum Phase: Hashable {
        case ready
        case solving
        case failed(reason: String)
        case completed
    }

    @Published var phase: Phase = .ready
    @Published var ringAngles: [Double] = [0, 0, 0] // degrees
    @Published var targets: [Double] = [0, 0, 0] // degrees
    @Published var rotationsLeft: Int? = nil
    @Published var trapHintVisible: Bool = false

    private(set) var level: Int = 1
    private(set) var difficulty: QuestStore.Difficulty = .easy

    private var startDate: Date?
    private var trapHideWorkItem: DispatchWorkItem?

    func configure(level: Int, difficulty: QuestStore.Difficulty) {
        self.level = max(1, level)
        self.difficulty = difficulty
        reset()
    }

    func reset() {
        phase = .ready
        ringAngles = makeInitialRingAngles(level: level)
        targets = makeTargets(level: level)
        startDate = nil
        trapHideWorkItem?.cancel()
        trapHideWorkItem = nil

        switch difficulty {
        case .easy:
            rotationsLeft = nil
        case .normal:
            rotationsLeft = max(8, 14 - level)
        case .hard:
            rotationsLeft = max(6, 12 - level)
        }
        trapHintVisible = false
    }

    func startIfNeeded() {
        guard case .ready = phase else { return }
        phase = .solving
        startDate = Date()
    }

    func elapsedSeconds(now: Date = Date()) -> Int {
        guard let startDate else { return 0 }
        return max(0, Int(now.timeIntervalSince(startDate).rounded(.down)))
    }

    func applyRingRotationDelta(_ index: Int, deltaDegrees: Double) {
        guard case .solving = phase else { return }
        guard ringAngles.indices.contains(index) else { return }

        // Whole-array assign so @Published emits and SwiftUI updates (subscript set does not).
        var next = ringAngles
        next[index] = normalize(next[index] + deltaDegrees)
        ringAngles = next

        if difficulty == .hard {
            maybeTriggerTrap(for: index)
        }

        if isSolved() {
            phase = .completed
        }
    }

    func registerRotationGestureEnded(totalMovementDegrees: Double) {
        guard case .solving = phase else { return }
        guard difficulty != .easy else { return }
        guard abs(totalMovementDegrees) > 1.5 else { return }

        rotationsLeft = (rotationsLeft ?? 0) - 1
        if let left = rotationsLeft, left < 0 {
            phase = .failed(reason: "You ran out of rotations.")
        }
    }

    func toggleHint() {
        guard difficulty == .hard else { return }
        trapHintVisible.toggle()
        if trapHintVisible {
            scheduleTrapHintHide(after: 2.0)
        } else {
            trapHideWorkItem?.cancel()
        }
    }

    private func scheduleTrapHintHide(after interval: TimeInterval) {
        trapHideWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.trapHintVisible = false
        }
        trapHideWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: item)
    }

    private func maybeTriggerTrap(for index: Int) {
        // Hidden trap: if ring drifts too far from target, it snaps back a bit.
        let diff = angularDistance(a: ringAngles[index], b: targets[index])
        if diff > 120 {
            var next = ringAngles
            next[index] = normalize(next[index] - 30)
            ringAngles = next
            trapHintVisible = true
            scheduleTrapHintHide(after: 1.2)
        }
    }

    /// Glyphs are 6‑fold symmetric; any `target + 60°·k` looks identical to the player.
    private func bestMatchDistance(ringAngle: Double, target: Double) -> Double {
        var best = angularDistance(a: ringAngle, b: target)
        for k in 1..<6 {
            let shifted = normalize(target + Double(k) * 60)
            best = min(best, angularDistance(a: ringAngle, b: shifted))
        }
        return best
    }

    private func isSolved() -> Bool {
        for i in 0..<3 {
            let tol: Double = (difficulty == .easy ? 16 : (difficulty == .normal ? 10 : 7))
            if bestMatchDistance(ringAngle: ringAngles[i], target: targets[i]) > tol {
                return false
            }
        }
        return true
    }

    private func makeTargets(level: Int) -> [Double] {
        let h = level * 47 + 13
        let base = Double(h % 360)
        let schemes: [(Double, Double, Double)] = [
            (12, 127, 241),
            (33, 148, 263),
            (54, 169, 284),
            (71, 193, 311),
            (24, 167, 279),
            (41, 201, 322),
        ]
        let o = schemes[(level - 1) % schemes.count]
        return [
            normalize(base + o.0),
            normalize(base + o.1),
            normalize(base + o.2),
        ]
    }

    private func makeInitialRingAngles(level: Int) -> [Double] {
        let a = Double((level * 19 + 7) % 360)
        let b = Double((level * 53 + 91) % 360)
        let c = Double((level * 29 + 173) % 360)
        return [a, b, c]
    }

    private func normalize(_ d: Double) -> Double {
        var v = d.truncatingRemainder(dividingBy: 360)
        if v < 0 { v += 360 }
        return v
    }

    private func angularDistance(a: Double, b: Double) -> Double {
        let diff = abs(normalize(a) - normalize(b))
        return min(diff, 360 - diff)
    }
}

