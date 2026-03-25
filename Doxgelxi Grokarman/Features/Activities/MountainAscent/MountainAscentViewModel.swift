//
//  MountainAscentViewModel.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import Foundation
import Combine

@MainActor
final class MountainAscentViewModel: ObservableObject {
    enum Phase: Hashable {
        case ready
        case climbing
        case failed(reason: String)
        case completed
    }

    @Published var phase: Phase = .ready
    @Published var segmentIndex: Int = 0
    @Published var segmentsTotal: Int = 5
    @Published var tension: Double = 0 // 0...1
    @Published var attempts: Int = 0
    @Published var windOffset: Double = 0
    @Published var showSlide: Bool = false

    private(set) var level: Int = 1
    private(set) var difficulty: QuestStore.Difficulty = .easy

    /// Matches `targetWindow(for: difficulty:)` for the active segment (for UI).
    var currentTensionWindow: ClosedRange<Double> {
        targetWindow(for: segmentIndex, difficulty: difficulty)
    }

    private static let segmentsByLevel: [Int] = [5, 6, 5, 7, 6, 8, 5, 7, 8, 6, 9, 7]

    private var startDate: Date?
    private var tick: AnyCancellable?
    private var holdingSince: Date?

    func configure(level: Int, difficulty: QuestStore.Difficulty) {
        self.level = max(1, level)
        self.difficulty = difficulty
        reset()
    }

    func reset() {
        phase = .ready
        segmentIndex = 0
        let idx = min(max(0, level - 1), Self.segmentsByLevel.count - 1)
        segmentsTotal = min(9, Self.segmentsByLevel[idx])
        tension = 0
        attempts = 0
        windOffset = 0
        showSlide = false
        startDate = nil
        holdingSince = nil
        tick?.cancel()
        tick = nil
    }

    func startIfNeeded() {
        guard case .ready = phase else { return }
        phase = .climbing
        startDate = Date()
        startTicker()
    }

    func elapsedSeconds(now: Date = Date()) -> Int {
        guard let startDate else { return 0 }
        return max(0, Int(now.timeIntervalSince(startDate).rounded(.down)))
    }

    func beginHold() {
        guard case .climbing = phase else { return }
        holdingSince = Date()
    }

    func endHold() {
        guard case .climbing = phase else { return }
        attempts += 1

        let window = targetWindow(for: segmentIndex, difficulty: difficulty)
        let success = tension >= window.lowerBound && tension <= window.upperBound

        if success {
            segmentIndex += 1
            tension = 0
            holdingSince = nil
            if segmentIndex >= segmentsTotal {
                phase = .completed
                tick?.cancel()
            }
        } else {
            if difficulty == .hard {
                triggerSlidePenalty()
            }
            if attempts >= maxAttempts(for: difficulty) {
                phase = .failed(reason: "You lost your grip.")
                tick?.cancel()
            } else {
                tension = 0
                holdingSince = nil
            }
        }
    }

    private func startTicker() {
        tick?.cancel()
        tick = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.tick(now: now)
            }
    }

    private func tick(now: Date) {
        guard case .climbing = phase else { return }

        if difficulty != .easy {
            let windBase = difficulty == .hard ? 1.15 : 0.88
            let windBeat = 0.07 * Double(level % 6)
            windOffset = sin(now.timeIntervalSinceReferenceDate * (windBase + windBeat)) * Double(9 + level % 3)
        } else {
            windOffset = 0
        }

        guard let holdingSince else { return }

        let holdTime = now.timeIntervalSince(holdingSince)
        let pace = 1.0 + Double(level % 5) * 0.035
        let speed = ((difficulty == .hard ? 0.9 : (difficulty == .normal ? 0.75 : 0.6)) + Double(level) * 0.018) * pace
        let next = min(1, max(0, holdTime * speed / 1.8))
        tension = next
    }

    private func targetWindow(for segment: Int, difficulty: QuestStore.Difficulty) -> ClosedRange<Double> {
        let t = Double(level * 2 + segment * 3 + 1) * 0.73
        let wobble = sin(t) * 0.11 + cos(Double(level + segment) * 0.5) * 0.05
        let baseCenter = 0.54 + wobble + (Double(segment % 3) - 1) * 0.045
        let width: Double
        switch difficulty {
        case .easy: width = 0.26
        case .normal: width = 0.18
        case .hard: width = 0.12
        }
        let lower = max(0.10, baseCenter - width / 2)
        let upper = min(0.95, baseCenter + width / 2)
        return lower...upper
    }

    private func maxAttempts(for difficulty: QuestStore.Difficulty) -> Int {
        switch difficulty {
        case .easy: return 999
        case .normal: return 8
        case .hard: return 6
        }
    }

    private func triggerSlidePenalty() {
        showSlide = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            self?.showSlide = false
        }
        segmentIndex = max(0, segmentIndex - 1)
    }
}

