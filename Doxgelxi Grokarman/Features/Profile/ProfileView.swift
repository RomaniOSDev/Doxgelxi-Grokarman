//
//  ProfileView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: QuestStore
    @State private var showResetConfirm: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Profile")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appTextPrimary, Color.appAccent.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.appPrimary.opacity(0.18), radius: 10, x: 0, y: 5)
                    .padding(.top, 8)

                StatsCard(totalStars: store.totalStars,
                          activitiesPlayed: store.activitiesPlayedCount,
                          totalTime: store.totalPlaySeconds)

                NavigationLink {
                    SettingsView()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.appAccent)
                            .frame(width: 36, alignment: .center)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            Text("Rate us, privacy, and terms")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.75)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.appTextSecondary.opacity(0.7))
                    }
                    .padding(16)
                    .appCardChrome(cornerRadius: 18, elevated: true)
                }
                .buttonStyle(.plain)

                VStack(spacing: 12) {
                    Button {
                        showResetConfirm = true
                    } label: {
                        Text("Reset All Progress")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .id(store.revision)
        .alert("Reset Progress?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAll()
            }
        } message: {
            Text("This will clear all stars, unlocks, and statistics.")
        }
    }
}

private struct StatsCard: View {
    let totalStars: Int
    let activitiesPlayed: Int
    let totalTime: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            StatLine(title: "Total stars", value: "\(totalStars)")
            StatLine(title: "Activities played", value: "\(activitiesPlayed)")
            StatLine(title: "Total time", value: formattedTime(totalTime))
        }
        .padding(16)
        .appCardChrome(cornerRadius: 18, elevated: true)
    }

    private func formattedTime(_ seconds: Int) -> String {
        let s = max(0, seconds)
        let h = s / 3600
        let m = (s % 3600) / 60
        let r = s % 60

        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(r)s" }
        return "\(r)s"
    }
}

private struct StatLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
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
        .padding(.vertical, 2)
    }
}

