//
//  ActivityGlyphView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

/// Vector “icon” for each activity route (Canvas), shared by Home and Adventures.
struct ActivityGlyphView: View {
    let activity: QuestStore.ActivityID

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface.opacity(0.72), Color.appBackground.opacity(0.58)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppDecor.panelStroke, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppDecor.panelInsetShine)
                        .blendMode(.plusLighter)
                )

            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size).insetBy(dx: 10, dy: 10)

                switch activity {
                case .mysticForest:
                    let trunk = Path(roundedRect: CGRect(x: rect.midX - 6, y: rect.midY - 2, width: 12, height: rect.height * 0.55), cornerRadius: 4)
                    context.fill(trunk, with: .color(.appAccent.opacity(0.85)))
                    let canopy = Path(ellipseIn: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * 0.65))
                    context.fill(canopy, with: .color(.appPrimary.opacity(0.9)))

                case .mountainAscent:
                    var mountain = Path()
                    mountain.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                    mountain.addLine(to: CGPoint(x: rect.midX - 8, y: rect.minY + 10))
                    mountain.addLine(to: CGPoint(x: rect.midX + 6, y: rect.minY + 22))
                    mountain.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                    mountain.closeSubpath()
                    context.fill(mountain, with: .color(.appPrimary.opacity(0.85)))
                    let ridge = Path { p in
                        p.move(to: CGPoint(x: rect.midX - 14, y: rect.minY + 26))
                        p.addLine(to: CGPoint(x: rect.midX + 6, y: rect.minY + 22))
                        p.addLine(to: CGPoint(x: rect.midX - 2, y: rect.minY + 44))
                        p.closeSubpath()
                    }
                    context.fill(ridge, with: .color(.appTextPrimary.opacity(0.20)))

                case .ruinsOfTime:
                    let ring = Path(ellipseIn: rect)
                    context.stroke(ring, with: .color(.appAccent), lineWidth: 5)
                    let glyph = Path { p in
                        p.move(to: CGPoint(x: rect.midX, y: rect.minY + 8))
                        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 8))
                        p.move(to: CGPoint(x: rect.minX + 8, y: rect.midY))
                        p.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.midY))
                    }
                    context.stroke(glyph, with: .color(.appPrimary.opacity(0.85)), lineWidth: 3)
                }
            }
        }
        .shadow(color: Color.black.opacity(0.38), radius: 10, x: 0, y: 6)
        .shadow(color: Color.appPrimary.opacity(0.14), radius: 14, x: 0, y: 8)
    }
}
