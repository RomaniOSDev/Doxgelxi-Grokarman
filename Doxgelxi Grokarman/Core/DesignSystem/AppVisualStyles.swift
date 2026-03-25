//
//  AppVisualStyles.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

// MARK: - Gradients (asset colors only)

enum AppDecor {
    static let screenBase = LinearGradient(
        colors: [
            Color.appBackground,
            Color.appSurface.opacity(0.42),
            Color.appBackground
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let screenDepth = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.22),
            Color.clear,
            Color.appBackground.opacity(0.75)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let screenTopGlow = RadialGradient(
        colors: [
            Color.appPrimary.opacity(0.20),
            Color.appAccent.opacity(0.08),
            Color.clear
        ],
        center: .top,
        startRadius: 40,
        endRadius: 480
    )

    static let panelFill = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.98),
            Color.appSurface.opacity(0.78),
            Color.appBackground.opacity(0.40)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panelStroke = LinearGradient(
        colors: [
            Color.appAccent.opacity(0.45),
            Color.appAccent.opacity(0.12),
            Color.appPrimary.opacity(0.22)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panelInsetShine = LinearGradient(
        colors: [
            Color.appTextPrimary.opacity(0.10),
            Color.clear
        ],
        startPoint: .top,
        endPoint: .center
    )

    static let primaryButtonFill = LinearGradient(
        colors: [
            Color.appPrimary,
            Color.appPrimary.opacity(0.82),
            Color.appAccent.opacity(0.58)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButtonHighlight = LinearGradient(
        colors: [
            Color.appTextPrimary.opacity(0.18),
            Color.clear
        ],
        startPoint: .top,
        endPoint: UnitPoint(x: 0.5, y: 0.55)
    )

    static let secondaryButtonFill = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.95),
            Color.appSurface.opacity(0.72),
            Color.appBackground.opacity(0.50)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let tabBarFill = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.98),
            Color.appSurface.opacity(0.88),
            Color.appBackground.opacity(0.92)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - View modifiers

extension View {
    /// Full-screen backdrop: layered gradients + soft top light.
    func appScreenBackground() -> some View {
        background {
            ZStack {
                AppDecor.screenBase
                AppDecor.screenDepth
                AppDecor.screenTopGlow
            }
            .ignoresSafeArea()
        }
    }

    /// Raised card: gradient fill, rim light, double shadow.
    func appCardChrome(cornerRadius: CGFloat = 18, elevated: Bool = true) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppDecor.panelFill)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppDecor.panelStroke, lineWidth: 1)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppDecor.panelInsetShine)
                        .blendMode(.plusLighter)
                        .padding(1)
                        .allowsHitTesting(false)
                }
                .shadow(color: Color.black.opacity(elevated ? 0.38 : 0.24), radius: elevated ? 18 : 12, x: 0, y: elevated ? 10 : 6)
                .shadow(color: Color.appPrimary.opacity(0.12), radius: 22, x: 0, y: 14)
        }
    }

    /// Activity / playfield panel inside a screen (slightly deeper).
    func appPlayfieldPanel(cornerRadius: CGFloat = 22) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppDecor.panelFill)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppDecor.panelStroke, lineWidth: 1.2)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.appTextPrimary.opacity(0.06), lineWidth: 1)
                        .padding(2)
                }
                .shadow(color: Color.black.opacity(0.45), radius: 22, x: 0, y: 14)
                .shadow(color: Color.appAccent.opacity(0.14), radius: 28, x: 0, y: 18)
        }
    }
}
