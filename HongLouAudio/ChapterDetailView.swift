//
//  ChapterDetailView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/31.
//

import SwiftUI

struct ChapterDetailView: View {
    let groupedChapter: GroupedChapter
    @ObservedObject private var theme = ThemeManager.shared
    let favoritesManager: FavoritesManager
    
    // Character image name to character name mapping
    private let characterNameMap: [String: String] = [
        "jia_baoyu": "贾宝玉",
        "lin_daiyu": "林黛玉",
        "xue_baochai": "薛宝钗",
        "wang_xifeng": "王熙凤",
        "jia_mu": "贾母",
        "jia_zheng": "贾政",
        "jia_yuanchun": "贾元春",
        "xi_ren": "袭人",
        "qing_wen": "晴雯",
        "miao_yu": "妙玉",
        "shi_xiangyun": "史湘云",
        "jia_tanchun": "贾探春",
        "jia_yingchun": "贾迎春",
        "jia_xichun": "贾惜春",
        "yuan_yang": "鸳鸯",
        "qin_keqing": "秦可卿",
        "ping_er": "平儿",
        "jia_lian": "贾琏",
        "liu_laolao": "刘姥姥"
    ]
    
    @State private var randomCharacterImageName: String = ""
    @State private var randomCharacterName: String = ""
    @State private var isImageZoomed = false

    var body: some View {
        ZStack {
            VStack {
                List(groupedChapter.parts) { part in
                    HStack(spacing: 0) {
                        // Main area: navigate to audio player (with 边听边看)
                        NavigationLink(destination: AudioPlayerView(chapter: part)) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(groupedChapter.chapterNumber)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(theme.accentRed)
                                        .clipShape(Circle())

                                    Text(partLabel(from: part.title))
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(theme.primaryText)

                                    // Show book icon if text is available
                                    if !part.chapterText.isEmpty {
                                        Image(systemName: "book.pages.fill")
                                            .font(.caption)
                                            .foregroundColor(theme.tertiaryText)
                                    }

                                    Spacer()
                                }

                                Text(part.summary)
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryText)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listRowBackground(theme.cardBackground)
                }
                .listStyle(PlainListStyle())

                // Random character image section with actual character name
                if !randomCharacterImageName.isEmpty && !randomCharacterName.isEmpty {
                    VStack(spacing: 8) {
                        Text(randomCharacterName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.primaryText)

                        if let uiImage = UIImage(named: randomCharacterImageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 160, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(theme.accentRed, lineWidth: 1)
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        isImageZoomed = true
                                    }
                                }
                        } else {
                            // Fallback placeholder if image not found
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.cardBackground)
                                .frame(width: 160, height: 160)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(theme.accentRed, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                }
            }

            // Full-screen zoomed image overlay
            if isImageZoomed {
                Color.black.opacity(0.85)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isImageZoomed = false
                        }
                    }

                VStack {
                    if let uiImage = UIImage(named: randomCharacterImageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                    }

                    Text(randomCharacterName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 16)
                }
            }
        }
        .onAppear {
            // Select a random character image and name each time the view appears
            let characterImageNames = Array(characterNameMap.keys)
            let randomIndex = Int.random(in: 0..<characterImageNames.count)
            randomCharacterImageName = characterImageNames[randomIndex]
            randomCharacterName = characterNameMap[randomCharacterImageName] ?? "未知人物"
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    if groupedChapter.titleLines.count >= 3 {
                        HStack(alignment: .center, spacing: 4) {
                            Text(groupedChapter.titleLines[0])
                                .font(.system(size: 11))
                                .foregroundColor(theme.tertiaryText)
                                .fixedSize()
                            VStack(alignment: .leading, spacing: 0) {
                                Text(groupedChapter.titleLines[1])
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(theme.primaryText)
                                Text(groupedChapter.titleLines[2])
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                    } else {
                        Text(groupedChapter.displayTitle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.primaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    favoritesManager.toggleFavorite(groupedChapter.chapterNumber)
                }) {
                    Image(systemName: favoritesManager.isFavorite(groupedChapter.chapterNumber) ? "heart.fill" : "heart")
                        .foregroundColor(favoritesManager.isFavorite(groupedChapter.chapterNumber) ? .red : .gray)
                        .font(.title3)
                }
            }
        }
        .background(
            theme.pageBackground // Soft antique paper background
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// Return "clause 上", "clause 下", or "中"
    /// e.g. "甄士隐梦幻识通灵 上", "贾雨村风尘怀闺秀 下"
    private func partLabel(from title: String) -> String {
        let parts = title.components(separatedBy: " ")
        guard let last = parts.last, ["上", "中", "下"].contains(last) else { return "" }

        // Drop "第X回" prefix and "上/中/下" suffix → remaining clauses
        let clauses = Array(parts.dropFirst().dropLast())

        switch last {
        case "上": return clauses.count >= 1 ? "\(clauses[0]) 上" : "上"
        case "下": return clauses.count >= 2 ? "\(clauses[1]) 下" : "下"
        case "中": return "中"
        default: return last
        }
    }
}

#Preview {
    // Create sample data for preview
    let sampleParts = [
        Chapter(number: 5, title: "第三回 贾夫人仙逝扬州城 冷子兴演说荣国府 上", audioFileName: "5.mp3", summary: "Sample summary for part 1", textFileName: nil, paragraphTimestamps: nil),
        Chapter(number: 6, title: "第三回 贾夫人仙逝扬州城 冷子兴演说荣国府 下", audioFileName: "6.mp3", summary: "Sample summary for part 2", textFileName: nil, paragraphTimestamps: nil)
    ]
    let sampleGrouped = GroupedChapter(chapterNumber: 3, titlePrefix: "第三回 贾夫人仙逝扬州城 冷子兴演说荣国府", parts: sampleParts)
    ChapterDetailView(groupedChapter: sampleGrouped, favoritesManager: FavoritesManager())
}
