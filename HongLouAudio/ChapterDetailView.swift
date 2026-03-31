//
//  ChapterDetailView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/31.
//

import SwiftUI

struct ChapterDetailView: View {
    let groupedChapter: GroupedChapter
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
    
    var body: some View {
        VStack {
            List(groupedChapter.parts) { part in
                NavigationLink(destination: AudioPlayerView(chapter: part)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            // Display the chapter number (回号) instead of individual part number
                            Text("\(groupedChapter.chapterNumber)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red
                                .clipShape(Circle())
                            
                            // Extract the part suffix (上, 中, 下) from the title
                            Text(extractPartSuffix(from: part.title))
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1)) // Deep brown
                            
                            Spacer()
                        }
                        
                        Text(part.summary)
                            .font(.caption)
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2)) // Warm brown
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(red: 0.96, green: 0.94, blue: 0.90)) // Antique paper color
            }
            .listStyle(PlainListStyle())
            
            // Random character image section with actual character name
            if !randomCharacterImageName.isEmpty && !randomCharacterName.isEmpty {
                VStack(spacing: 8) {
                    Text(randomCharacterName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                    
                    if let uiImage = UIImage(named: randomCharacterImageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.6, green: 0.2, blue: 0.2), lineWidth: 1)
                            )
                    } else {
                        // Fallback placeholder if image not found
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.96, green: 0.94, blue: 0.90))
                            .frame(width: 160, height: 160)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.6, green: 0.2, blue: 0.2), lineWidth: 2)
                            )
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
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
            Color(red: 0.98, green: 0.96, blue: 0.92) // Soft antique paper background
                .ignoresSafeArea()
        )
        .navigationTitle(groupedChapter.displayTitle)
    }
    
    private func extractPartSuffix(from title: String) -> String {
        if title.hasSuffix(" 上") {
            return "上"
        } else if title.hasSuffix(" 中") {
            return "中"
        } else if title.hasSuffix(" 下") {
            return "下"
        }
        return ""
    }
}

#Preview {
    // Create sample data for preview
    let sampleParts = [
        Chapter(number: 5, title: "第三回 贾夫人仙逝扬州城 冷子兴演说荣国府 上", audioFileName: "5.mp3", summary: "Sample summary for part 1"),
        Chapter(number: 6, title: "第三回 贾夫人仙逝扬州城 冷子兴演说荣国府 下", audioFileName: "6.mp3", summary: "Sample summary for part 2")
    ]
    let sampleGrouped = GroupedChapter(chapterNumber: 3, titlePrefix: "第三回 贾夫人仙逝扬州城 冷子兴演说荣国府", parts: sampleParts)
    return ChapterDetailView(groupedChapter: sampleGrouped, favoritesManager: FavoritesManager())
}
