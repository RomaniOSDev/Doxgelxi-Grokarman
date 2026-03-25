//
//  OnboardingView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: QuestStore
    @State private var pageIndex: Int = 0

    private let pages: [OnboardingPage] = [
        .init(
            title: "Choose your path",
            body: "Pick an adventure and a difficulty. Each level rewards you with stars based on performance.",
            artwork: .compass
        ),
        .init(
            title: "Play with gestures",
            body: "Drag, hold, and rotate to overcome obstacles. Every action matters on harder routes.",
            artwork: .gestures
        ),
        .init(
            title: "Unlock new levels",
            body: "Earn stars to progress. Replay levels to improve your rating and reach new story arcs.",
            artwork: .stars
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer(minLength: 12)

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                            .padding(.horizontal, 16)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 520)

                HStack(spacing: 12) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            pageIndex = max(0, pageIndex - 1)
                        }
                    } label: {
                        Text("Back")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(pageIndex == 0)

                    Button {
                        if pageIndex < pages.count - 1 {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                pageIndex += 1
                            }
                        } else {
                            store.hasSeenOnboarding = true
                        }
                    } label: {
                        Text(pageIndex < pages.count - 1 ? "Next" : "Start")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 20)
            }
        }
        .scrollIndicators(.hidden)
        .appScreenBackground()
    }
}

private struct OnboardingPage {
    enum Artwork {
        case compass
        case gestures
        case stars
    }

    let title: String
    let body: String
    let artwork: Artwork
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var animate: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                OnboardingArtwork(artwork: page.artwork, animate: animate)
                    .padding(28)
            }
            .frame(height: 320)
            .appCardChrome(cornerRadius: 28, elevated: true)
            .onAppear {
                animate = false
                withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                    animate = true
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appTextPrimary, Color.appAccent.opacity(0.88)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.appPrimary.opacity(0.16), radius: 8, x: 0, y: 4)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)

                Text(page.body)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct OnboardingArtwork: View {
    let artwork: OnboardingPage.Artwork
    let animate: Bool

    var body: some View {
        switch artwork {
        case .compass:
            CompassIllustration(animate: animate)
        case .gestures:
            GestureIllustration(animate: animate)
        case .stars:
            StarGateIllustration(animate: animate)
        }
    }
}

private struct CompassIllustration: View {
    let animate: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appBackground.opacity(0.55))
                .overlay(Circle().stroke(Color.appAccent.opacity(0.35), lineWidth: 2))

            Circle()
                .trim(from: 0, to: animate ? 1 : 0.05)
                .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.2), value: animate)

            Path { p in
                let c = CGPoint(x: 0.5, y: 0.5)
                p.move(to: CGPoint(x: c.x, y: c.y - 0.22))
                p.addLine(to: CGPoint(x: c.x + 0.09, y: c.y + 0.18))
                p.addLine(to: CGPoint(x: c.x, y: c.y + 0.10))
                p.addLine(to: CGPoint(x: c.x - 0.09, y: c.y + 0.18))
                p.closeSubpath()
            }
            .fill(Color.appPrimary)
            .scaleEffect(animate ? 1 : 0.85)
            .rotationEffect(.degrees(animate ? 18 : -10))
            .animation(.spring(response: 0.9, dampingFraction: 0.6), value: animate)

            Circle()
                .fill(Color.appTextPrimary.opacity(0.10))
                .frame(width: animate ? 16 : 10, height: animate ? 16 : 10)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: animate)
        }
        .drawingGroup()
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct GestureIllustration: View {
    let animate: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.appBackground.opacity(0.5))

            Path { p in
                p.move(to: CGPoint(x: 0.12, y: 0.76))
                p.addCurve(to: CGPoint(x: 0.88, y: 0.32),
                           control1: CGPoint(x: 0.30, y: 0.18),
                           control2: CGPoint(x: 0.64, y: 0.92))
            }
            .trim(from: 0, to: animate ? 1 : 0.15)
            .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
            .animation(.easeInOut(duration: 1.2), value: animate)

            Circle()
                .fill(Color.appPrimary)
                .frame(width: 22, height: 22)
                .offset(x: animate ? 88 : -88, y: animate ? -64 : 64)
                .animation(.spring(response: 1.0, dampingFraction: 0.65), value: animate)
        }
        .drawingGroup()
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct StarGateIllustration: View {
    let animate: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appBackground.opacity(0.55))

            ForEach(0..<8, id: \.self) { i in
                Capsule(style: .continuous)
                    .fill(Color.appAccent.opacity(0.35))
                    .frame(width: 10, height: 44)
                    .offset(y: -90)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .opacity(animate ? 1 : 0.2)
                    .animation(.easeInOut(duration: 0.9).delay(Double(i) * 0.03), value: animate)
            }

            StarShape(points: 5, innerRatio: 0.45)
                .fill(Color.appPrimary)
                .shadow(color: Color.appPrimary.opacity(animate ? 0.55 : 0.15), radius: animate ? 18 : 4, x: 0, y: 0)
                .scaleEffect(animate ? 1 : 0.82)
                .animation(.spring(response: 0.9, dampingFraction: 0.6), value: animate)
        }
        .drawingGroup()
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct StarShape: Shape {
    let points: Int
    let innerRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) * 0.36
        let innerR = outerR * innerRatio
        let step = .pi / CGFloat(points)
        var angle: CGFloat = -.pi / 2

        var path = Path()
        var firstPoint = true

        for i in 0..<(points * 2) {
            let r = (i % 2 == 0) ? outerR : innerR
            let pt = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            if firstPoint {
                path.move(to: pt)
                firstPoint = false
            } else {
                path.addLine(to: pt)
            }
            angle += step
        }
        path.closeSubpath()
        return path
    }
}

