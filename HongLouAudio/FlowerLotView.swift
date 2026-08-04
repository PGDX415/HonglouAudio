//
//  FlowerLotView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct FlowerLotView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var drawnSlip: FlowerSlip? = nil
    @State private var isDrawing = false
    @State private var showSlip = false
    @State private var slipOpacity: Double = 0
    @State private var floatingFlowers: [FloatingFlower] = []

    private let cream = Color(red: 0.96, green: 0.93, blue: 0.86)
    private let gold = Color(red: 0.75, green: 0.55, blue: 0.35)
    private let ink = Color(red: 0.2, green: 0.1, blue: 0.05)

    var body: some View {
        ZStack {
            // Background — rice paper with subtle floral
            cream.ignoresSafeArea()

            // Watercolor stains
            watercolorEffect

            // Floating flower petals
            ForEach(floatingFlowers) { f in
                Text(f.petal)
                    .font(.system(size: f.size))
                    .opacity(f.opacity)
                    .position(x: f.x, y: f.y)
                    .rotationEffect(.degrees(f.rotation))
            }

            VStack(spacing: 0) {
                Spacer()

                if drawnSlip == nil || !showSlip {
                    drawingState
                } else {
                    resultView(drawnSlip!)
                }

                Spacer()
            }

            // Navigation
            VStack {
                HStack {
                    Spacer()
                    Button(action: { resetOrDismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(ink.opacity(0.3))
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onAppear { spawnPetals() }
    }

    // MARK: - Watercolor Background

    private var watercolorEffect: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.8, blue: 0.85).opacity(0.15))
                    .frame(width: 200, height: 200)
                    .position(x: geo.size.width * 0.2, y: geo.size.height * 0.25)
                    .blur(radius: 40)

                Circle()
                    .fill(Color(red: 0.9, green: 0.85, blue: 0.7).opacity(0.12))
                    .frame(width: 250, height: 250)
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.65)
                    .blur(radius: 50)

                Circle()
                    .fill(Color(red: 0.9, green: 0.7, blue: 0.75).opacity(0.1))
                    .frame(width: 180, height: 180)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.45)
                    .blur(radius: 45)
            }
        }
    }

    // MARK: - Drawing State

    private var drawingState: some View {
        VStack(spacing: 0) {
            // Title
            VStack(spacing: 8) {
                Text("🌺")
                    .font(.system(size: 40))
                    .padding(.bottom, 4)

                Text("花 名 签")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(ink)
                    .tracking(8)

                Text("寿怡红群芳开夜宴 · 第六十三回")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(ink.opacity(0.4))
                    .tracking(2)
            }
            .padding(.bottom, 24)

            // Flower cluster
            ZStack {
                ForEach(Array(allFlowerEmojis.enumerated()), id: \.offset) { i, emoji in
                    let angle = Double(i) * 2 * .pi / Double(allFlowerEmojis.count)
                    let radius: CGFloat = isDrawing ? 90 : 70
                    Text(emoji)
                        .font(.system(size: isDrawing ? 32 : 26))
                        .offset(
                            x: cos(angle) * radius,
                            y: sin(angle) * radius
                        )
                        .rotationEffect(.degrees(isDrawing ? Double.random(in: -30...30) : 0))
                        .animation(.easeInOut(duration: 0.8).repeatCount(isDrawing ? 3 : 0), value: isDrawing)
                        .scaleEffect(isDrawing ? CGFloat.random(in: 0.7...1.3) : 1.0)
                        .animation(.easeInOut(duration: 0.3).repeatCount(isDrawing ? 5 : 0), value: isDrawing)
                }
            }
            .frame(width: 200, height: 200)
            .padding(.bottom, 28)

            // Instruction
            Text("轻点花朵\n抽取属于你的花名签")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(ink.opacity(0.45))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.bottom, 16)

            // Draw button
            Button(action: { drawFlower() }) {
                Text("抽取花签")
                    .font(.system(size: 15, design: .serif))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.8, green: 0.35, blue: 0.4), Color(red: 0.6, green: 0.2, blue: 0.3)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color(red: 0.5, green: 0.1, blue: 0.2).opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isDrawing)
            .opacity(isDrawing ? 0.5 : 1)
        }
    }

    private var allFlowerEmojis: [String] {
        ["🌸", "🌺", "🌼", "🏵️", "🌹", "💐", "🌷", "🌻", "🪷", "💮", "🌿", "🍂"]
    }

    // MARK: - Result View

    private func resultView(_ slip: FlowerSlip) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Flower card
                VStack(spacing: 0) {
                    // Flower emoji
                    Text(slip.emoji)
                        .font(.system(size: 56))
                        .padding(.bottom, 8)

                    // Original badge
                    if slip.isOriginal {
                        Text("原著第六十三回原签")
                            .font(.system(size: 10, design: .serif))
                            .foregroundColor(gold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(gold.opacity(0.1))
                            .cornerRadius(6)
                            .padding(.bottom, 16)
                    } else {
                        Spacer().frame(height: 16)
                    }

                    // Title
                    Text(slip.title)
                        .font(.system(size: 22, design: .serif))
                        .foregroundColor(slip.color)
                        .tracking(6)
                        .padding(.bottom, 4)

                    // Flower name
                    HStack(spacing: 4) {
                        Text(slip.flower)
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(ink)
                    }
                    .padding(.bottom, 16)

                    // Divider
                    HStack(spacing: 6) {
                        Rectangle().fill(slip.color.opacity(0.3)).frame(width: 30, height: 1)
                        Text("签 语")
                            .font(.system(size: 10, design: .serif))
                            .foregroundColor(slip.color.opacity(0.6))
                            .tracking(4)
                        Rectangle().fill(slip.color.opacity(0.3)).frame(width: 30, height: 1)
                    }
                    .padding(.bottom, 12)

                    // Verse
                    Text(slip.verse)
                        .font(.system(size: 20, design: .serif))
                        .foregroundColor(ink)
                        .padding(.bottom, 4)

                    Text("—— \(slip.verseSource)")
                        .font(.system(size: 10, design: .serif))
                        .foregroundColor(ink.opacity(0.4))
                        .padding(.bottom, 20)

                    // Character match
                    VStack(spacing: 6) {
                        Text("签主")
                            .font(.system(size: 10, design: .serif))
                            .foregroundColor(ink.opacity(0.4))
                            .tracking(4)

                        Text(slip.character)
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(slip.color)

                        Text(slip.characterDesc)
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(ink.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 8)
                    }
                    .padding(16)
                    .background(slip.color.opacity(0.06))
                    .cornerRadius(12)
                    .padding(.horizontal, 36)
                    .padding(.bottom, 20)

                    // Divider
                    HStack(spacing: 6) {
                        Rectangle().fill(slip.color.opacity(0.3)).frame(width: 20, height: 1)
                        Circle().fill(slip.color.opacity(0.5)).frame(width: 3, height: 3)
                        Rectangle().fill(slip.color.opacity(0.3)).frame(width: 20, height: 1)
                    }
                    .padding(.bottom, 16)

                    // Fortune
                    Text(slip.fortune)
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(ink.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 36)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 24)

                    // Share
                    Button(action: { shareSlip(slip) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.caption2)
                            Text("分享花签")
                                .font(.system(size: 12, design: .serif))
                        }
                        .foregroundColor(slip.color)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(slip.color.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(slip.color.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .opacity(slipOpacity)
                .scaleEffect(slipOpacity)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: slipOpacity)

                Spacer().frame(height: 20)

                // Draw again
                Button(action: { drawFlower() }) {
                    Text("再抽一签")
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(ink.opacity(0.4))
                }
            }
        }
    }

    // MARK: - Actions

    private func drawFlower() {
        isDrawing = true
        spawnPetals()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.4)) {
                drawnSlip = FlowerLotStore.drawSlip()
                isDrawing = false
                showSlip = true
                slipOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    slipOpacity = 1
                }
            }
        }
    }

    private func resetOrDismiss() {
        if showSlip {
            drawnSlip = nil
            showSlip = false
            slipOpacity = 0
        }
    }

    private func shareSlip(_ slip: FlowerSlip) {
        let card = FlowerShareCard(slip: slip)
        let cardSize = CGSize(width: 390, height: 580)
        if let image = ShareCardRenderer.render(card, size: cardSize) {
            ShareCardRenderer.share(image: image)
        }
    }

    private func spawnPetals() {
        floatingFlowers = (0..<15).map { _ in
            FloatingFlower(
                petal: ["🌸", "🌺", "💮", "🏵️", "🌷", "🍂"].randomElement()!,
                x: CGFloat.random(in: 30...360),
                y: CGFloat.random(in: 80...700),
                size: CGFloat.random(in: 10...20),
                opacity: Double.random(in: 0.15...0.4),
                rotation: Double.random(in: 0...360)
            )
        }
    }
}

// MARK: - Floating Flower Model

struct FloatingFlower: Identifiable {
    let id = UUID()
    let petal: String
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let rotation: Double
}

// MARK: - Share Card

struct FlowerShareCard: View {
    let slip: FlowerSlip

    private let cream = Color(red: 0.96, green: 0.93, blue: 0.86)
    private let ink = Color(red: 0.2, green: 0.1, blue: 0.05)
    private let gold = Color(red: 0.75, green: 0.55, blue: 0.35)
    private let cardW: CGFloat = 390
    private let cardH: CGFloat = 580

    var body: some View {
        ZStack {
            cream

            // Border
            RoundedRectangle(cornerRadius: 0)
                .stroke(slip.color.opacity(0.3), lineWidth: 1)
                .padding(12)

            VStack(spacing: 0) {
                Spacer().frame(height: 30)

                Text(slip.emoji)
                    .font(.system(size: 48))
                    .padding(.bottom, 8)

                if slip.isOriginal {
                    Text("原著第六十三回 · 花名签")
                        .font(.system(size: 9, design: .serif))
                        .foregroundColor(gold)
                        .tracking(2)
                        .padding(.bottom, 16)
                }

                Text(slip.title)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(slip.color)
                    .tracking(6)

                Text(slip.flower)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(ink)
                    .padding(.bottom, 14)

                Text("「\(slip.verse)」")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(ink)
                    .padding(.bottom, 4)

                Text("—— \(slip.verseSource)")
                    .font(.system(size: 9, design: .serif))
                    .foregroundColor(ink.opacity(0.4))
                    .padding(.bottom, 20)

                Text("签主：\(slip.character)")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(slip.color)
                    .padding(.bottom, 16)

                Text(slip.fortune)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(ink.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)

                Spacer()

                Text("红楼聆梦 · 花名签")
                    .font(.system(size: 9, design: .serif))
                    .foregroundColor(gold.opacity(0.5))
                    .tracking(4)
                    .padding(.bottom, 28)
            }
        }
        .frame(width: cardW, height: cardH)
    }
}

#Preview {
    FlowerLotView()
}
