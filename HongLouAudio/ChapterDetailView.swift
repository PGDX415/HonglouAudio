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
    @ObservedObject var favoritesManager: FavoritesManager
    
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
        "liu_laolao": "刘姥姥",
        "qiao_jie": "巧姐",
        "li_wan": "李纨",
        "xiang_ling": "香菱",
        "zi_juan": "紫鹃",
        "you_sanjie": "尤三姐",
        "jia_she": "贾赦",
        "zhen_shiyin": "甄士隐",
        "jia_yucun": "贾雨村",
        "jia_yun": "贾芸",
        "you_shi": "尤氏",
        "xing_furen": "邢夫人"
    ]

    /// 每回的核心人物画像映射（基于情节确定最标志性的人物）
    private static let chapterMainCharacter: [Int: String] = [
        1: "zhen_shiyin", 2: "jia_yucun", 3: "lin_daiyu", 4: "jia_yucun",
        5: "jia_baoyu", 6: "liu_laolao", 7: "jia_baoyu", 8: "xue_baochai",
        9: "jia_baoyu", 10: "qin_keqing", 11: "wang_xifeng", 12: "lin_daiyu",
        13: "wang_xifeng", 14: "jia_baoyu", 15: "wang_xifeng", 16: "jia_yuanchun",
        17: "jia_baoyu", 18: "jia_yuanchun", 19: "xi_ren", 20: "wang_xifeng",
        21: "shi_xiangyun", 22: "jia_baoyu", 23: "lin_daiyu", 24: "jia_yun",
        25: "jia_baoyu", 26: "jia_baoyu", 27: "lin_daiyu", 28: "jia_baoyu",
        29: "jia_mu", 30: "xue_baochai", 31: "xi_ren", 32: "jia_baoyu",
        33: "jia_baoyu", 34: "xue_baochai", 35: "jia_baoyu", 36: "jia_tanchun",
        37: "jia_tanchun", 38: "jia_tanchun", 39: "liu_laolao", 40: "liu_laolao",
        41: "wang_xifeng", 42: "liu_laolao", 43: "jia_mu", 44: "wang_xifeng",
        45: "lin_daiyu", 46: "yuan_yang", 47: "jia_she", 48: "xiang_ling",
        49: "shi_xiangyun", 50: "jia_tanchun", 51: "xue_baochai", 52: "ping_er",
        53: "jia_mu", 54: "jia_mu", 55: "jia_tanchun", 56: "jia_tanchun",
        57: "zi_juan", 58: "xue_baochai", 59: "jia_baoyu", 60: "jia_baoyu",
        61: "ping_er", 62: "shi_xiangyun", 63: "jia_baoyu", 64: "lin_daiyu",
        65: "you_sanjie", 66: "you_sanjie", 67: "wang_xifeng", 68: "wang_xifeng",
        69: "you_sanjie", 70: "lin_daiyu", 71: "jia_mu", 72: "yuan_yang",
        73: "jia_yingchun", 74: "qing_wen", 75: "jia_tanchun", 76: "lin_daiyu",
        77: "qing_wen", 78: "qing_wen", 79: "jia_yingchun", 80: "xiang_ling",
        81: "jia_baoyu", 82: "lin_daiyu", 83: "jia_yuanchun", 84: "jia_baoyu",
        85: "xue_baochai", 86: "jia_yuanchun", 87: "miao_yu", 88: "jia_mu",
        89: "jia_baoyu", 90: "jia_baoyu", 91: "jia_baoyu", 92: "jia_zheng",
        93: "jia_baoyu", 94: "jia_baoyu", 95: "jia_yuanchun", 96: "jia_baoyu",
        97: "lin_daiyu", 98: "lin_daiyu", 99: "jia_zheng", 100: "jia_tanchun",
        101: "wang_xifeng", 102: "you_shi", 103: "wang_xifeng", 104: "jia_yun",
        105: "jia_zheng", 106: "jia_mu", 107: "jia_zheng", 108: "xue_baochai",
        109: "jia_baoyu", 110: "jia_mu", 111: "yuan_yang", 112: "miao_yu",
        113: "wang_xifeng", 114: "wang_xifeng", 115: "jia_xichun", 116: "jia_baoyu",
        117: "jia_baoyu", 118: "jia_xichun", 119: "jia_baoyu", 120: "jia_baoyu",
    ]
    
    @State private var displayCharacterImageName: String = ""
    @State private var displayCharacterName: String = ""
    @State private var isImageZoomed = false
    @State private var readerChapter: Chapter? = nil
    @State private var selectedPart: Chapter? = nil
    @State private var showGuide = false

    private var chapterGuide: ChapterGuide? {
        ChapterGuideStore.guideFor(chapterNumber: groupedChapter.chapterNumber)
    }

    var body: some View {
        ZStack {
            VStack {
                // Chapter guide card
                if let guide = chapterGuide {
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showGuide.toggle() } }) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.1))
                                Text("本回导读")
                                    .font(.system(size: 13, weight: .semibold, design: .serif))
                                    .foregroundColor(theme.primaryText)
                                Spacer()
                                Image(systemName: showGuide ? "chevron.up" : "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(theme.tertiaryText)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(PlainButtonStyle())

                        if showGuide {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(guide.summary)
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(theme.secondaryText)
                                    .lineSpacing(5)

                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .font(.caption2)
                                        .foregroundColor(theme.accentRed.opacity(0.6))
                                    Text(guide.keyCharacters.joined(separator: " · "))
                                        .font(.system(size: 11, design: .serif))
                                        .foregroundColor(theme.accentRed.opacity(0.8))
                                }
                                .padding(.top, 2)

                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.caption2)
                                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.1))
                                    Text(guide.highlight)
                                        .font(.system(size: 11, design: .serif))
                                        .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.1))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        }
                    }
                    .background(theme.cardBackground)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                }

                List(groupedChapter.parts) { part in
                    VStack(spacing: 0) {
                        // Main area: navigate to audio player (with 边听边看)
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

                                Spacer()

                                // Download status per audio file
                                partDownloadIndicator(part)
                            }

                            Text(part.summary)
                                .font(.caption)
                                .foregroundColor(theme.secondaryText)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPart = part
                        }

                        // Separate "阅读正文" button when text is available
                        if !part.chapterText.isEmpty {
                            Button(action: { readerChapter = part }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "book.pages.fill")
                                        .font(.caption)
                                    Text("阅读正文（含注释与批注）")
                                        .font(.caption)
                                    Spacer()
                                }
                                .foregroundColor(theme.accentRed)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(theme.accentRed.opacity(0.06))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                        }
                    }
                    .listRowBackground(theme.cardBackground)
                }
                .listStyle(PlainListStyle())

                // Random character image section with actual character name
                if !displayCharacterImageName.isEmpty && !displayCharacterName.isEmpty {
                    VStack(spacing: 8) {
                        Text(displayCharacterName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.primaryText)

                        if let uiImage = UIImage(named: displayCharacterImageName) {
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

            // Navigation handled via .navigationDestination

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
                    if let uiImage = UIImage(named: displayCharacterImageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                    }

                    Text(displayCharacterName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 16)
                }
            }
        }
        .onAppear {
            // Select the most relevant character for this chapter
            let chapterNum = groupedChapter.chapterNumber
            if let imageName = Self.chapterMainCharacter[chapterNum],
               let name = characterNameMap[imageName] {
                displayCharacterImageName = imageName
                displayCharacterName = name
            } else {
                // Fallback: random selection
                let keys = Array(characterNameMap.keys)
                let idx = Int.random(in: 0..<keys.count)
                displayCharacterImageName = keys[idx]
                displayCharacterName = characterNameMap[displayCharacterImageName] ?? "未知人物"
            }
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
        .navigationDestination(item: $selectedPart) { part in
            AudioPlayerView(chapter: part)
        }
        .sheet(item: $readerChapter) { chapter in
            NavigationStack {
                ChapterReaderView(chapter: chapter)
            }
        }
    }
    
    /// Download status indicator for a single audio part
    @ViewBuilder
    private func partDownloadIndicator(_ part: Chapter) -> some View {
        let dm = AudioDownloadManager.shared
        if dm.isDownloaded(part.audioFileName) {
            Image(systemName: "checkmark.icloud.fill")
                .font(.caption)
                .foregroundColor(.green.opacity(0.7))
        } else if dm.activeDownloads.contains(part.audioFileName) {
            if let progress = dm.downloadProgress[part.audioFileName] {
                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(Color.orange, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(progress * 100))")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.orange)
                }
            } else {
                ProgressView()
                    .scaleEffect(0.6)
            }
        } else if !dm.remoteBaseURL.isEmpty {
            Button(action: { dm.download(fileName: part.audioFileName) }) {
                Image(systemName: "icloud.and.arrow.down")
                    .font(.caption)
                    .foregroundColor(theme.accentRed.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
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
        Chapter(number: 5, title: "第三回 贾夫人仙逝扬州城 冷子兴演说荣国府 上", audioFileName: "5.mp3", summary: "Sample summary for part 1", textFileName: nil, paragraphTimestamps: nil, season: 1),
        Chapter(number: 6, title: "第三回 贾夫人仙逝扬州城 冷子兴演说荣国府 下", audioFileName: "6.mp3", summary: "Sample summary for part 2", textFileName: nil, paragraphTimestamps: nil, season: 1)
    ]
    let sampleGrouped = GroupedChapter(chapterNumber: 3, titlePrefix: "第三回 贾夫人仙逝扬州城 冷子兴演说荣国府", parts: sampleParts)
    ChapterDetailView(groupedChapter: sampleGrouped, favoritesManager: FavoritesManager())
}
