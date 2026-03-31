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
    
    var body: some View {
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
        .listStyle(PlainListStyle())
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