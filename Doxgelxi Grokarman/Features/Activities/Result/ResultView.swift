//
//  ResultView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct ResultView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: QuestStore

    let result: ActivityResult
    let onRetry: () -> Void
    let onNext: () -> Void
    let onBackToLevels: () -> Void

    @State private var showStar: [Bool] = [false, false, false]
    @State private var showBanner: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer(minLength: 8)

                ZStack(alignment: .top) {
                    VStack(spacing: 14) {
                        HStack {
                            Text("Level \(result.level)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                            Text(result.difficulty.title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }

                        HStack(spacing: 10) {
                            ForEach(0..<3, id: \.self) { i in
                                Image(systemName: i < result.stars ? "star.fill" : "star")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(i < result.stars ? Color.appAccent : Color.appTextSecondary.opacity(0.45))
                                    .scaleEffect(showStar[i] ? 1.0 : 0.2)
                                    .opacity(showStar[i] ? 1.0 : 0.0)
                                    .shadow(color: Color.appAccent.opacity(i < result.stars ? 0.55 : 0.0), radius: 18, x: 0, y: 0)
                            }
                        }
                        .frame(minHeight: 56)

                        VStack(alignment: .leading, spacing: 8) {
                            StatRow(label: "Time", value: timeString(result.elapsedSeconds))
                            ForEach(result.detailLines, id: \.self) { line in
                                Text(line)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.appTextSecondary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if result.improvedBest {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.up.right.circle.fill")
                                    .foregroundStyle(Color.appAccent)
                                Text("New best score saved.")
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppDecor.panelFill)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(AppDecor.panelStroke, lineWidth: 1)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(AppDecor.panelInsetShine)
                                            .blendMode(.plusLighter)
                                    )
                            }
                            .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(16)

                    if showBanner {
                        AchievementBanner(text: bannerText)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .padding(.top, -8)
                    }
                }
                .appCardChrome(cornerRadius: 22, elevated: true)
                .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    Button {
                        onNext()
                    } label: {
                        Text(result.level < store.levelsPerActivity ? "Next Level" : "Back to Levels")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button {
                        onRetry()
                    } label: {
                        Text("Retry")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button {
                        onBackToLevels()
                    } label: {
                        Text("Back to Levels")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 20)
            }
        }
        .appScreenBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.appTextPrimary)
                .accessibilityLabel("Back")
            }
        }
        .onAppear {
            animateStars()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.25)) {
                showBanner = true
            }
        }
    }

    private var bannerText: String {
        if let first = result.newAchievementTitles.first {
            return "Achievement unlocked: \(first)"
        }
        if result.stars > 0 {
            return "Level complete"
        }
        return "So close — try again"
    }

    private func animateStars() {
        showStar = [false, false, false]
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.15 * Double(i))) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.68)) {
                    showStar[i] = true
                }
            }
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let s = max(0, seconds)
        let m = s / 60
        let r = s % 60
        return m > 0 ? "\(m)m \(r)s" : "\(r)s"
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 4)
    }
}

private struct AchievementBanner: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.appTextPrimary)
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background {
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
        }
        .shadow(color: Color.appPrimary.opacity(0.55), radius: 20, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
}

