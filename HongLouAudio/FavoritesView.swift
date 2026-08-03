//
//  FavoritesView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/31.
//

import SwiftUI

struct FavoritesView: View {
    @State private var groupedChapters: [GroupedChapter] = []
    @ObservedObject private var theme = ThemeManager.shared
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some View {
        NavigationView {
            List(favoritedChapters) { groupedChapter in
                NavigationLink(destination: ChapterDetailView(groupedChapter: groupedChapter, favoritesManager: favoritesManager)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(groupedChapter.chapterNumber)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(theme.accentRed) // Classical red
                                .clipShape(Circle())
                            
                            Text(groupedChapter.displayTitle)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(theme.primaryText) // Deep brown
                            
                            Spacer()
                            
                            // Favorite button (always filled since these are favorites)
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                        }
                        
                        // Show summary of first part as representative summary
                        if let firstPartSummary = groupedChapter.parts.first?.summary {
                            Text(firstPartSummary)
                                .font(.caption)
                                .foregroundColor(theme.secondaryText) // Warm brown
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(theme.cardBackground) // Antique paper color
            }
            .navigationTitle("收藏")
            .onAppear {
                let allChapters = ChapterLoader.loadChapters()
                groupedChapters = allChapters.groupByHui()
            }
            .listStyle(PlainListStyle())
            .background(
                theme.pageBackground // Soft antique paper background
                    .ignoresSafeArea()
            )
        }
        .accentColor(theme.accentRed) // Classical red accent
    }
    
    private var favoritedChapters: [GroupedChapter] {
        return groupedChapters.filter { favoritesManager.isFavorite($0.chapterNumber) }
    }
}

#Preview {
    FavoritesView()
}