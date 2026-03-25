//
//  DifficultyPickerView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct DifficultyPickerView: View {
    @Binding var selection: QuestStore.Difficulty

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Difficulty")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)

            HStack(spacing: 10) {
                ForEach(QuestStore.Difficulty.allCases) { difficulty in
                    let isOn = selection == difficulty
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selection = difficulty }
                    } label: {
                        Text(difficulty.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundStyle(isOn ? Color.appTextPrimary : Color.appTextSecondary)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        isOn
                                            ? LinearGradient(
                                                colors: [
                                                    Color.appPrimary.opacity(0.38),
                                                    Color.appPrimary.opacity(0.12),
                                                    Color.appSurface.opacity(0.35)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            : LinearGradient(
                                                colors: [
                                                    Color.appSurface.opacity(0.65),
                                                    Color.appBackground.opacity(0.45)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(
                                                Color.appAccent.opacity(isOn ? 0.52 : 0.16),
                                                lineWidth: 1
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(AppDecor.panelInsetShine)
                                            .blendMode(.plusLighter)
                                            .opacity(isOn ? 0.75 : 0.35)
                                    )
                            }
                            .shadow(color: Color.black.opacity(isOn ? 0.32 : 0.18), radius: isOn ? 10 : 5, x: 0, y: isOn ? 6 : 3)
                            .shadow(color: Color.appPrimary.opacity(isOn ? 0.18 : 0), radius: 14, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(difficulty.title)
                }
            }
        }
        .padding(16)
        .appCardChrome(cornerRadius: 18, elevated: true)
    }
}
