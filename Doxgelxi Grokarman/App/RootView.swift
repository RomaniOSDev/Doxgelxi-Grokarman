//
//  RootView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: QuestStore

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .appScreenBackground()
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("QuestStore.didResetAll"))) { _ in
            // Views react through store.revision; this ensures any local stacks also refresh if needed.
        }
    }
}

