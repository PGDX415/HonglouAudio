//
//  FortuneView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct FortuneView: View {
    @State private var drawnSlip: FortuneSlip? = nil
    @State private var isDrawing = false
    @State private var showSlip = false
    @State private var slipOpacity: Double = 0
    @State private var shakeCount = 0
    @State private var particles: [FortuneParticle] = []
    @Environment(\.dismiss) private var dismiss

    // Fixed colors for the mystic theme
    private let vermillion = Color(red: 0.55, green: 0.08, blue: 0.08)
    private let deepRed = Color(red: 0.25, green: 0.02, blue: 0.02)
    private let gold = Color(red: 0.8, green: 0.65, blue: 0.35)
    private let cream = Color(red: 0.96, green: 0.93, blue: 0.86)

    var body: some View {
        ZStack {
            // Background — dark mystic atmosphere
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.05, blue: 0.05),
                    deepRed,
                    Color(red: 0.1, green: 0.03, blue: 0.03)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Floating particles
            ForEach(particles) { particle in
                Circle()
                    .fill(gold.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .animation(.easeOut(duration: 2), value: particles.count)
            }

            // Incense smoke effect
            smokeTrails

            VStack(spacing: 0) {
                Spacer()

                if drawnSlip == nil || !showSlip {
                    // Draw state
                    drawingState
                } else {
                    // Result state
                    resultView(drawnSlip!)
                }

                Spacer()
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismissOrReset() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(gold.opacity(0.6))
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onShake {
            if drawnSlip == nil || showSlip {
                drawFortune()
            }
        }
        .onAppear {
            spawnParticles()
        }
    }

    // MARK: - Drawing State

    private var drawingState: some View {
        VStack(spacing: 0) {
            // Title
            VStack(spacing: 8) {
                Text("太虚幻境")
                    .font(.system(size: 20, design: .serif))
                    .foregroundColor(gold.opacity(0.7))
                    .tracking(8)

                Text("金陵十二钗 · 判词签")
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(gold.opacity(0.4))
                    .tracking(4)
            }
            .padding(.bottom, 40)

            // Fortune tube visualization
            ZStack {
                // Bamboo tube
                RoundedRectangle(cornerRadius: 8)
                    .stroke(gold.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 60, height: 160)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.35, green: 0.25, blue: 0.1), Color(red: 0.25, green: 0.18, blue: 0.08)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .cornerRadius(8)
                    )

                // Slips inside
                VStack(spacing: 4) {
                    ForEach(0..<8, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(gold.opacity(0.3))
                            .frame(width: 20, height: 4)
                            .offset(x: isDrawing ? CGFloat.random(in: -5...5) : 0)
                            .offset(y: isDrawing ? CGFloat.random(in: -3...3) : 0)
                    }
                }
                .animation(.easeInOut(duration: 0.1).repeatCount(10), value: shakeCount)

                // One slip rising
                if isDrawing {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(gold)
                        .frame(width: 22, height: 6)
                        .offset(y: -60)
                        .transition(.move(edge: .bottom))
                }
            }
            .padding(.bottom, 24)

            // Instruction
            Text(isDrawing ? "签筒轻摇..." : "摇一摇手机\n或轻点求签")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(gold.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.bottom, 20)

            // Draw button
            Button(action: { drawFortune() }) {
                HStack(spacing: 6) {
                    Image(systemName: "hand.draw.fill")
                        .font(.caption)
                    Text("求一支签")
                        .font(.system(size: 15, design: .serif))
                }
                .foregroundColor(deepRed)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(gold)
                .cornerRadius(20)
            }
            .disabled(isDrawing)
            .opacity(isDrawing ? 0.5 : 1)
        }
    }

    // MARK: - Result View

    private func resultView(_ slip: FortuneSlip) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Slip card
                VStack(spacing: 0) {
                    // Level badge
                    HStack {
                        Image(systemName: slip.level.icon)
                            .font(.caption)
                        Text(slip.level.rawValue)
                            .font(.system(size: 13, design: .serif))
                    }
                    .foregroundColor(slip.level.color)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(slip.level.color.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.bottom, 20)

                    // Verse
                    Text(slip.verse)
                        .font(.system(size: 18, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)

                    // Source
                    Text("—— \(slip.source)")
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(gold.opacity(0.5))
                        .padding(.bottom, 20)

                    // Divider
                    HStack(spacing: 8) {
                        Rectangle().fill(gold.opacity(0.3)).frame(width: 30, height: 1)
                        Circle().fill(gold.opacity(0.5)).frame(width: 4, height: 4)
                        Rectangle().fill(gold.opacity(0.3)).frame(width: 30, height: 1)
                    }
                    .padding(.bottom, 20)

                    // Keyword
                    Text(slip.keyword)
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(gold)
                        .padding(.bottom, 20)

                    // Guidance
                    Text(slip.guidance)
                        .font(.system(size: 15, design: .serif))
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(7)
                        .padding(.horizontal, 16)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 24)

                    // Share button
                    Button(action: { shareSlip(slip) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.caption)
                            Text("分享签文")
                                .font(.system(size: 13, design: .serif))
                        }
                        .foregroundColor(gold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(gold.opacity(0.4), lineWidth: 1)
                        )
                    }
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(gold.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .opacity(slipOpacity)
                .scaleEffect(slipOpacity)
                .animation(.easeOut(duration: 0.8), value: slipOpacity)

                Spacer().frame(height: 24)

                // Draw again
                Button(action: { drawFortune() }) {
                    Text("再求一签")
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(gold.opacity(0.6))
                }
            }
        }
    }

    // MARK: - Smoke Trails

    private var smokeTrails: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(gold.opacity(0.03))
                        .frame(width: CGFloat(40 + i * 30), height: CGFloat(40 + i * 30))
                        .position(
                            x: geo.size.width * (0.3 + CGFloat(i) * 0.2),
                            y: geo.size.height * (0.6 - CGFloat(i) * 0.15)
                        )
                        .blur(radius: 20)

                    Circle()
                        .fill(gold.opacity(0.02))
                        .frame(width: CGFloat(60 + i * 40), height: CGFloat(60 + i * 40))
                        .position(
                            x: geo.size.width * (0.6 + CGFloat(i) * 0.15),
                            y: geo.size.height * (0.7 - CGFloat(i) * 0.1)
                        )
                        .blur(radius: 30)
                }
            }
        }
    }

    // MARK: - Actions

    private func drawFortune() {
        isDrawing = true
        shakeCount += 1
        spawnParticles()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.5)) {
                drawnSlip = FortuneStore.drawSlip()
                isDrawing = false
                showSlip = true
                // Track draw count for achievement
                let count = UserDefaults.standard.integer(forKey: "fortune_draw_count") + 1
                UserDefaults.standard.set(count, forKey: "fortune_draw_count")
                slipOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.8)) {
                    slipOpacity = 1
                }
            }
        }
    }

    private func dismissOrReset() {
        if showSlip {
            drawnSlip = nil
            showSlip = false
            slipOpacity = 0
        } else {
            dismiss()
        }
    }

    private func shareSlip(_ slip: FortuneSlip) {
        let card = FortuneShareCard(slip: slip)
        let cardSize = CGSize(width: 390, height: 620)
        if let image = ShareCardRenderer.render(card, size: cardSize) {
            ShareCardRenderer.share(image: image)
        }
    }

    private func spawnParticles() {
        particles = (0..<12).map { _ in
            FortuneParticle(
                x: CGFloat.random(in: 50...350),
                y: CGFloat.random(in: 100...700),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.1...0.4)
            )
        }
    }
}

// MARK: - Particle Model

struct FortuneParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

// MARK: - Share Card

struct FortuneShareCard: View {
    let slip: FortuneSlip

    private let deepRed = Color(red: 0.2, green: 0.04, blue: 0.04)
    private let gold = Color(red: 0.8, green: 0.65, blue: 0.35)
    private let cardW: CGFloat = 390
    private let cardH: CGFloat = 620

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.04, blue: 0.04), deepRed],
                startPoint: .top,
                endPoint: .bottom
            )

            // Border
            RoundedRectangle(cornerRadius: 0)
                .stroke(gold.opacity(0.3), lineWidth: 1)
                .padding(12)

            // Content
            VStack(spacing: 0) {
                Spacer().frame(height: 30)

                Text("太虚幻境")
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(gold.opacity(0.7))
                    .tracking(6)

                Text("判词签")
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(gold.opacity(0.4))
                    .tracking(4)
                    .padding(.bottom, 30)

                // Level
                HStack {
                    Image(systemName: slip.level.icon)
                    Text(slip.level.rawValue)
                        .font(.system(size: 13, design: .serif))
                }
                .foregroundColor(slip.level.color)
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
                .background(slip.level.color.opacity(0.15))
                .cornerRadius(10)
                .padding(.bottom, 28)

                // Verse
                Text(slip.verse)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .padding(.horizontal, 36)
                    .padding(.bottom, 10)

                Text("—— \(slip.source)")
                    .font(.system(size: 10, design: .serif))
                    .foregroundColor(gold.opacity(0.5))
                    .padding(.bottom, 24)

                // Divider
                HStack(spacing: 6) {
                    Rectangle().fill(gold.opacity(0.3)).frame(width: 24, height: 1)
                    Circle().fill(gold.opacity(0.4)).frame(width: 3, height: 3)
                    Rectangle().fill(gold.opacity(0.3)).frame(width: 24, height: 1)
                }
                .padding(.bottom, 24)

                // Keyword
                Text(slip.keyword)
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(gold)
                    .padding(.bottom, 24)

                // Guidance
                Text(slip.guidance)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(Color.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    .padding(.horizontal, 40)

                Spacer()

                Text("红楼聆梦 · 求签问卜")
                    .font(.system(size: 9, design: .serif))
                    .foregroundColor(gold.opacity(0.3))
                    .tracking(4)
                    .padding(.bottom, 30)
            }
        }
        .frame(width: cardW, height: cardH)
    }
}

// MARK: - Shake Gesture

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

struct ShakeDetector: ViewModifier {
    let action: () -> Void
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetector(action: action))
    }
}

#Preview {
    FortuneView()
}
