//
//  MysticForestQuestViewModel.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import Foundation
import Combine
import CoreGraphics

@MainActor
final class MysticForestQuestViewModel: ObservableObject {
    struct Obstacle: Identifiable, Hashable {
        let id = UUID()
        var rect: CGRect // normalized 0...1
        var kind: Kind

        enum Kind: Hashable {
            case wall
            case movingTrap(axis: Axis)
        }

        enum Axis: Hashable {
            case x
            case y
        }
    }

    struct Rune: Identifiable, Hashable {
        let id = UUID()
        var center: CGPoint // normalized
        var collected: Bool = false
    }

    enum Phase: Hashable {
        case ready
        case playing
        case failed(reason: String)
        case completed
    }

    @Published var phase: Phase = .ready
    @Published var player: CGPoint = CGPoint(x: 0.12, y: 0.88)
    @Published var obstacles: [Obstacle] = []
    @Published var runes: [Rune] = []
    @Published var hits: Int = 0
    @Published var timeRemaining: Int? = nil

    private(set) var level: Int = 1
    private(set) var difficulty: QuestStore.Difficulty = .easy

    private var startDate: Date?
    private var tickCancellable: AnyCancellable?

    func configure(level: Int, difficulty: QuestStore.Difficulty) {
        self.level = max(1, level)
        self.difficulty = difficulty
        reset()
    }

    func reset() {
        phase = .ready
        player = makePlayerStart(level: level)
        hits = 0
        startDate = nil
        tickCancellable?.cancel()
        tickCancellable = nil

        obstacles = makeObstacles(level: level, difficulty: difficulty)
        runes = makeRunes(level: level)

        if difficulty == .hard {
            timeRemaining = max(11, 23 - level + (level % 3))
        } else {
            timeRemaining = nil
        }
    }

    func startIfNeeded() {
        guard case .ready = phase else { return }
        phase = .playing
        startDate = Date()
        startTicker()
    }

    func elapsedSeconds(now: Date = Date()) -> Int {
        guard let startDate else { return 0 }
        return max(0, Int(now.timeIntervalSince(startDate).rounded(.down)))
    }

    func updatePlayer(to normalized: CGPoint) {
        guard case .playing = phase else { return }
        let clamped = CGPoint(x: min(0.98, max(0.02, normalized.x)), y: min(0.98, max(0.02, normalized.y)))
        player = clamped
        step()
    }

    private func startTicker() {
        tickCancellable?.cancel()
        tickCancellable = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.tick(now: now)
            }
    }

    private func tick(now: Date) {
        guard case .playing = phase else { return }
        animateMovingTraps(now: now)
        if difficulty == .hard, let remaining = timeRemaining {
            let elapsed = elapsedSeconds(now: now)
            let next = max(0, remaining - elapsed)
            if next == 0 {
                phase = .failed(reason: "Time is up.")
                tickCancellable?.cancel()
            }
        }
        step()
    }

    private func animateMovingTraps(now: Date) {
        guard difficulty != .easy else { return }
        let t = now.timeIntervalSinceReferenceDate
        obstacles = obstacles.map { obstacle in
            guard case .movingTrap(let axis) = obstacle.kind else { return obstacle }
            var copy = obstacle
            let amplitude: CGFloat = difficulty == .hard ? 0.08 : 0.05
            let speed = (difficulty == .hard ? 1.2 : 0.9) + Double(level) * 0.03 + Double(level % 5) * 0.05
            let delta = CGFloat(sin(t * speed)) * amplitude
            switch axis {
            case .x:
                copy.rect.origin.x = clamp(copy.rect.origin.x + delta, min: 0.02, max: 0.98 - copy.rect.width)
            case .y:
                copy.rect.origin.y = clamp(copy.rect.origin.y + delta, min: 0.02, max: 0.98 - copy.rect.height)
            }
            return copy
        }
    }

    private func step() {
        guard case .playing = phase else { return }

        let playerRect = CGRect(x: player.x - 0.03, y: player.y - 0.03, width: 0.06, height: 0.06)

        if obstacles.contains(where: { $0.rect.intersects(playerRect) }) {
            hits += 1
            if difficulty == .easy {
                phase = .failed(reason: "You hit an obstacle.")
                tickCancellable?.cancel()
                return
            } else if hits >= (difficulty == .normal ? 2 : 1) {
                phase = .failed(reason: "Too many hits.")
                tickCancellable?.cancel()
                return
            }
        }

        runes = runes.map { rune in
            guard !rune.collected else { return rune }
            let r = CGRect(x: rune.center.x - 0.035, y: rune.center.y - 0.035, width: 0.07, height: 0.07)
            if r.intersects(playerRect) {
                var copy = rune
                copy.collected = true
                return copy
            }
            return rune
        }

        if isInFinishZone(player: player) && runes.allSatisfy(\.collected) {
            phase = .completed
            tickCancellable?.cancel()
        }
    }

    private func isInFinishZone(player: CGPoint) -> Bool {
        player.x >= 0.88 && player.y <= 0.14
    }

    private func makePlayerStart(level: Int) -> CGPoint {
        let dx = CGFloat((level * 3) % 5) * 0.024
        let dy = CGFloat((level * 2) % 4) * 0.022
        return CGPoint(
            x: min(0.22, max(0.06, 0.11 + dx)),
            y: min(0.93, max(0.78, 0.86 - dy))
        )
    }

    private func makeRunes(level: Int) -> [Rune] {
        let bump = CGFloat(level % 5) * 0.018
        let sets: [[CGPoint]] = [
            [CGPoint(x: 0.26, y: 0.72), CGPoint(x: 0.52, y: 0.52), CGPoint(x: 0.74, y: 0.30)],
            [CGPoint(x: 0.30, y: 0.66), CGPoint(x: 0.48, y: 0.40), CGPoint(x: 0.70, y: 0.58)],
            [CGPoint(x: 0.22, y: 0.50), CGPoint(x: 0.56, y: 0.70), CGPoint(x: 0.72, y: 0.36)],
            [CGPoint(x: 0.34, y: 0.76), CGPoint(x: 0.58, y: 0.44), CGPoint(x: 0.44, y: 0.62)],
            [CGPoint(x: 0.28, y: 0.58), CGPoint(x: 0.50, y: 0.78), CGPoint(x: 0.68, y: 0.42)],
            [CGPoint(x: 0.24, y: 0.64), CGPoint(x: 0.54, y: 0.56), CGPoint(x: 0.76, y: 0.34)],
        ]
        let pts = sets[(level - 1) % sets.count]
        return pts.map { p in
            let x = min(0.9, max(0.08, p.x + bump * 0.5))
            let y = min(0.9, max(0.08, p.y - bump * 0.35))
            return Rune(center: CGPoint(x: x, y: y))
        }
    }

    private func addGates(_ obs: inout [Obstacle], level: Int) {
        let gapShift = CGFloat((level % 4)) * 0.028 + CGFloat((level / 4) % 2) * 0.012
        obs.append(.init(rect: CGRect(x: 0.24, y: 0.35 + gapShift, width: 0.16, height: 0.05), kind: .wall))
        obs.append(.init(rect: CGRect(x: 0.46, y: 0.60 - gapShift, width: 0.16, height: 0.05), kind: .wall))
        obs.append(.init(rect: CGRect(x: 0.68, y: 0.46 + gapShift * 0.9, width: 0.16, height: 0.05), kind: .wall))
    }

    private func addMovingTraps(_ obs: inout [Obstacle], level: Int, difficulty: QuestStore.Difficulty) {
        guard difficulty != .easy else { return }
        let p = level % 4
        switch p {
        case 0:
            obs.append(.init(rect: CGRect(x: 0.30, y: 0.22, width: 0.10, height: 0.05), kind: .movingTrap(axis: .x)))
            obs.append(.init(rect: CGRect(x: 0.58, y: 0.72, width: 0.10, height: 0.05), kind: .movingTrap(axis: .x)))
        case 1:
            obs.append(.init(rect: CGRect(x: 0.26, y: 0.68, width: 0.11, height: 0.05), kind: .movingTrap(axis: .x)))
            obs.append(.init(rect: CGRect(x: 0.62, y: 0.30, width: 0.05, height: 0.11), kind: .movingTrap(axis: .y)))
        case 2:
            obs.append(.init(rect: CGRect(x: 0.44, y: 0.48, width: 0.10, height: 0.05), kind: .movingTrap(axis: .x)))
            obs.append(.init(rect: CGRect(x: 0.72, y: 0.62, width: 0.05, height: 0.10), kind: .movingTrap(axis: .y)))
        default:
            obs.append(.init(rect: CGRect(x: 0.34, y: 0.18, width: 0.09, height: 0.05), kind: .movingTrap(axis: .x)))
            obs.append(.init(rect: CGRect(x: 0.54, y: 0.76, width: 0.10, height: 0.05), kind: .movingTrap(axis: .x)))
            obs.append(.init(rect: CGRect(x: 0.16, y: 0.44, width: 0.05, height: 0.10), kind: .movingTrap(axis: .y)))
        }
        if difficulty == .hard {
            obs.append(.init(rect: CGRect(x: 0.78, y: 0.22, width: 0.05, height: 0.12), kind: .movingTrap(axis: .y)))
        }
    }

    private func makeObstacles(level: Int, difficulty: QuestStore.Difficulty) -> [Obstacle] {
        var obs: [Obstacle] = []
        let layout = (level - 1) % 6

        switch layout {
        case 0:
            obs.append(.init(rect: CGRect(x: 0.18, y: 0.15, width: 0.06, height: 0.72), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.40, y: 0.15, width: 0.06, height: 0.60), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.62, y: 0.28, width: 0.06, height: 0.59), kind: .wall))
        case 1:
            obs.append(.init(rect: CGRect(x: 0.20, y: 0.22, width: 0.06, height: 0.52), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.44, y: 0.34, width: 0.06, height: 0.58), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.66, y: 0.16, width: 0.06, height: 0.48), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.52, y: 0.78, width: 0.22, height: 0.05), kind: .wall))
        case 2:
            obs.append(.init(rect: CGRect(x: 0.16, y: 0.42, width: 0.22, height: 0.06), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.50, y: 0.20, width: 0.06, height: 0.50), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.62, y: 0.52, width: 0.18, height: 0.06), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.36, y: 0.68, width: 0.06, height: 0.24), kind: .wall))
        case 3:
            obs.append(.init(rect: CGRect(x: 0.24, y: 0.12, width: 0.06, height: 0.42), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.38, y: 0.54, width: 0.06, height: 0.40), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.56, y: 0.18, width: 0.06, height: 0.56), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.72, y: 0.48, width: 0.06, height: 0.38), kind: .wall))
        case 4:
            obs.append(.init(rect: CGRect(x: 0.14, y: 0.28, width: 0.28, height: 0.05), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.30, y: 0.48, width: 0.06, height: 0.40), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.48, y: 0.26, width: 0.06, height: 0.52), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.68, y: 0.36, width: 0.06, height: 0.50), kind: .wall))
        default:
            obs.append(.init(rect: CGRect(x: 0.22, y: 0.58, width: 0.34, height: 0.05), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.42, y: 0.12, width: 0.06, height: 0.38), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.60, y: 0.62, width: 0.06, height: 0.30), kind: .wall))
            obs.append(.init(rect: CGRect(x: 0.70, y: 0.22, width: 0.12, height: 0.06), kind: .wall))
        }

        addGates(&obs, level: level)
        addMovingTraps(&obs, level: level, difficulty: difficulty)
        return obs
    }

    private func clamp(_ v: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, v))
    }
}

