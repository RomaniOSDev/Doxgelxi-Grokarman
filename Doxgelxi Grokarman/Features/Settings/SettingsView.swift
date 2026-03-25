//
//  SettingsView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
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

                VStack(spacing: 12) {
                    Button {
                        rateApp()
                    } label: {
                        SettingsRowLabel(
                            systemImage: "star.fill",
                            title: "Rate Us",
                            subtitle: "Leave a review on the App Store"
                        )
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    ForEach(AppPolicyLink.allCases, id: \.rawValue) { link in
                        Button {
                            openPolicy(link)
                        } label: {
                            SettingsRowLabel(
                                systemImage: link.systemImage,
                                title: link.title,
                                subtitle: link.subtitle
                            )
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openPolicy(_ link: AppPolicyLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

private struct SettingsRowLabel: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 36, alignment: .center)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(subtitle)
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
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: 56)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
