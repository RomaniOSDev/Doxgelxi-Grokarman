//
//  MainTabView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct MainTabView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case home
        case achievements
        case profile

        var id: String { rawValue }

        var title: String {
            switch self {
            case .home: return "Home"
            case .achievements: return "Achievements"
            case .profile: return "Profile"
            }
        }

        var systemImage: String {
            switch self {
            case .home: return "house.fill"
            case .achievements: return "sparkles"
            case .profile: return "person.crop.circle"
            }
        }
    }

    @State private var tab: Tab = .home

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch tab {
                case .home:
                    NavigationStack { HomeView() }
                case .achievements:
                    NavigationStack { AchievementsView() }
                case .profile:
                    NavigationStack { ProfileView() }
                }
            }

            CustomTabBar(selection: $tab)
        }
        .appScreenBackground()
    }
}

private struct CustomTabBar: View {
    @Binding var selection: MainTabView.Tab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MainTabView.Tab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { selection = tab }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(minWidth: 44, minHeight: 24)
                        Text(tab.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .foregroundStyle(selection == tab ? Color.appTextPrimary : Color.appTextSecondary)
                    .background {
                        if selection == tab {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.appPrimary.opacity(0.48),
                                            Color.appPrimary.opacity(0.18),
                                            Color.appAccent.opacity(0.12)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.appAccent.opacity(0.40), lineWidth: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(AppDecor.panelInsetShine)
                                        .blendMode(.plusLighter)
                                )
                                .shadow(color: Color.appPrimary.opacity(0.40), radius: 12, x: 0, y: 6)
                                .shadow(color: Color.black.opacity(0.30), radius: 8, x: 0, y: 4)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            ZStack(alignment: .top) {
                AppDecor.tabBarFill
                    .ignoresSafeArea(edges: .bottom)
                LinearGradient(
                    colors: [Color.appAccent.opacity(0.35), Color.appPrimary.opacity(0.12), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 2)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appTextPrimary.opacity(0.12), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 1)
            }
            .shadow(color: Color.black.opacity(0.55), radius: 24, x: 0, y: -8)
            .shadow(color: Color.appPrimary.opacity(0.12), radius: 32, x: 0, y: -14)
        }
    }
}

