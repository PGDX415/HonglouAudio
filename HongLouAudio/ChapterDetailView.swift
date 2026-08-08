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
        "jia_she": "贾赦"
    ]
    
    @State private var randomCharacterImageName: String = ""
    @State private var randomCharacterName: String = ""
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
