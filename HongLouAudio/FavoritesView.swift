//
//  FavoritesView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/31.
//

import SwiftUI

struct FavoritesView: View {
    @State private var groupedChapters: [GroupedChapter] = []
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
                                .background(Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red
                                .clipShape(Circle())
                            
                            Text(groupedChapter.displayTitle)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1)) // Deep brown
                            
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
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2)) // Warm brown
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(red: 0.96, green: 0.94, blue: 0.90)) // Antique paper color
            }
            .navigationTitle("收藏")
            .onAppear {
                let allChapters = ChapterLoader.loadChapters()
                groupedChapters = allChapters.groupByHui()
            }
            .listStyle(PlainListStyle())
            .background(
                Color(red: 0.98, green: 0.96, blue: 0.92) // Soft antique paper background
                    .ignoresSafeArea()
            )
        }
        .accentColor(Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red accent
    }
    
    private var favoritedChapters: [GroupedChapter] {
        return groupedChapters.filter { favoritesManager.isFavorite($0.chapterNumber) }
    }
}

#Preview {
    FavoritesView()
}