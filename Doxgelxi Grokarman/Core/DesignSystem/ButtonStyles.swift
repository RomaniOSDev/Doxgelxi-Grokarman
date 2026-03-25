//
//  ButtonStyles.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.appTextPrimary)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppDecor.primaryButtonFill)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppDecor.primaryButtonHighlight)
                        .blendMode(.plusLighter)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.appTextPrimary.opacity(0.22),
                                    Color.appAccent.opacity(0.35)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .opacity(configuration.isPressed ? 0.88 : 1.0)
            }
            .shadow(color: Color.appPrimary.opacity(configuration.isPressed ? 0.28 : 0.48), radius: 14, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.28), radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.appTextPrimary)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppDecor.secondaryButtonFill)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppDecor.panelInsetShine)
                        .blendMode(.plusLighter)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppDecor.panelStroke, lineWidth: 1)
                }
                .opacity(configuration.isPressed ? 0.88 : 1.0)
            }
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.22 : 0.34), radius: 12, x: 0, y: 7)
            .shadow(color: Color.appAccent.opacity(0.10), radius: 18, x: 0, y: 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}
