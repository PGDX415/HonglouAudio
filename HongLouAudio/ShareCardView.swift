//
//  ShareCardView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

// MARK: - Poem Share Card

struct PoemShareCard: View {
    let poem: Poem

    private let cardWidth: CGFloat = 390
    private let cardHeight: CGFloat = 600

    // Classical colors — fixed for brand identity, not theme-dependent
    private let ricePaper = Color(red: 0.96, green: 0.93, blue: 0.86)
    private let deepBrown = Color(red: 0.25, green: 0.12, blue: 0.05)
    private let accentGold = Color(red: 0.75, green: 0.55, blue: 0.35)
    private let vermillionRed = Color(red: 0.55, green: 0.08, blue: 0.08)

    var body: some View {
        ZStack {
            // Rice paper background
            ricePaper

            // Decorative border
            RoundedRectangle(cornerRadius: 0)
                .stroke(deepBrown.opacity(0.3), lineWidth: 1)
                .padding(12)
            RoundedRectangle(cornerRadius: 0)
                .stroke(deepBrown.opacity(0.15), lineWidth: 0.5)
                .padding(16)

            VStack(spacing: 0) {
                // Top ornament — gold line with center diamond
                topOrnament
                    .padding(.top, 40)

                // Category badge
                HStack(spacing: 5) {
                    Image(systemName: poem.category.iconName)
                        .font(.system(size: 11))
                    Text(poem.category.rawValue)
                        .font(.system(size: 11, design: .serif))
                }
                .foregroundColor(poem.category.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(poem.category.color.opacity(0.08))
                .cornerRadius(8)
                .padding(.top, 20)

                // Title
                Text(poem.title)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(vermillionRed)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal, 40)

                // Author
                Text(poem.author)
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(deepBrown.opacity(0.7))
                    .padding(.top, 8)

                // Decorative divider
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(accentGold.opacity(0.4))
                        .frame(width: 20, height: 1)
                    Circle()
                        .fill(accentGold.opacity(0.6))
                        .frame(width: 4, height: 4)
                    Rectangle()
                        .fill(accentGold.opacity(0.4))
                        .frame(width: 20, height: 1)
                }
                .padding(.top, 16)

                // Poem content
                ScrollView {
                    Text(poem.content)
                        .font(.system(size: 17, design: .serif))
                        .foregroundColor(deepBrown)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: 280)

                Spacer()

                // Bottom info
                VStack(spacing: 6) {
                    Text("—— 第\(poem.chapterNumber)回 ——")
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(deepBrown.opacity(0.5))
                        .tracking(2)

                    Text("红楼聆梦 · 有声珍藏版")
                        .font(.system(size: 10, design: .serif))
                        .foregroundColor(accentGold.opacity(0.7))
                        .tracking(4)
                }
                .padding(.bottom, 36)
            }
            .frame(width: cardWidth)
        }
        .frame(width: cardWidth, height: cardHeight)
    }

    // MARK: - Top Ornament

    private var topOrnament: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(accentGold.opacity(0.5))
                .frame(width: 80, height: 1)

            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(accentGold.opacity(0.5), lineWidth: 1)
                    .frame(width: 16, height: 16)
                    .rotationEffect(.degrees(45))

                Circle()
                    .fill(vermillionRed.opacity(0.8))
                    .frame(width: 5, height: 5)
            }

            Rectangle()
                .fill(accentGold.opacity(0.5))
                .frame(width: 80, height: 1)
        }
    }
}

// MARK: - Quote Share Card (for future use)

struct QuoteShareCard: View {
    let quote: String
    let character: String
    let chapterInfo: String

    private let cardWidth: CGFloat = 390
    private let cardHeight: CGFloat = 550

    private let ricePaper = Color(red: 0.96, green: 0.93, blue: 0.86)
    private let deepBrown = Color(red: 0.25, green: 0.12, blue: 0.05)
    private let accentGold = Color(red: 0.75, green: 0.55, blue: 0.35)
    private let vermillionRed = Color(red: 0.55, green: 0.08, blue: 0.08)

    var body: some View {
        ZStack {
            ricePaper

            RoundedRectangle(cornerRadius: 0)
                .stroke(deepBrown.opacity(0.3), lineWidth: 1)
                .padding(12)

            VStack(spacing: 0) {
                Spacer()

                // Large quotation mark
                Text("\u{201C}")
                    .font(.system(size: 64, design: .serif))
                    .foregroundColor(accentGold.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 36)
                    .offset(y: 16)

                // Quote text
                Text(quote)
                    .font(.system(size: 22, design: .serif))
                    .foregroundColor(deepBrown)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 8)

                // Ending quotation mark
                Text("\u{201D}")
                    .font(.system(size: 64, design: .serif))
                    .foregroundColor(accentGold.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 36)
                    .offset(y: -16)

                // Character attribution
                Text("—— \(character)")
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(vermillionRed)
                    .padding(.top, 8)

                Text(chapterInfo)
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(deepBrown.opacity(0.5))
                    .tracking(2)
                    .padding(.top, 4)

                Spacer()

                Text("红楼聆梦 · 有声珍藏版")
                    .font(.system(size: 10, design: .serif))
                    .foregroundColor(accentGold.opacity(0.7))
                    .tracking(4)
                    .padding(.bottom, 32)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

#Preview("Poem Card") {
    let poem = Poem(
        title: "葬花吟",
        author: "林黛玉",
        chapterNumber: 27,
        chapterTitle: "滴翠亭杨妃戏彩蝶 埋香冢飞燕泣残红",
        content: "花谢花飞花满天，红消香断有谁怜？\n游丝软系飘春榭，落絮轻沾扑绣帘。\n闺中女儿惜春暮，愁绪满怀无释处。\n手把花锄出绣帘，忍踏落花来复去。",
        appreciation: "",
        category: .诗,
        isFeatured: true
    )
    PoemShareCard(poem: poem)
}
