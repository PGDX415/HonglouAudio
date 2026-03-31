//
//  ContentView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/30.
//

import SwiftUI

struct ContentView: View {
    @State private var groupedChapters: [GroupedChapter] = []
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var searchText = ""
    
    var body: some View {
        List(filteredChapters) { groupedChapter in
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
                        
                        // Favorite button
                        Button(action: {
                            favoritesManager.toggleFavorite(groupedChapter.chapterNumber)
                        }) {
                            Image(systemName: favoritesManager.isFavorite(groupedChapter.chapterNumber) ? "heart.fill" : "heart")
                                .foregroundColor(favoritesManager.isFavorite(groupedChapter.chapterNumber) ? .red : .gray)
                                .font(.title3)
                        }
                        .buttonStyle(PlainButtonStyle())
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
        .searchable(text: $searchText, prompt: "搜索章回号或标题...")
        .onAppear {
            let allChapters = ChapterLoader.loadChapters()
            groupedChapters = allChapters.groupByHui()
        }
        .listStyle(PlainListStyle())
        .background(
            Color(red: 0.98, green: 0.96, blue: 0.92) // Soft antique paper background
                .ignoresSafeArea()
        )
        .navigationTitle("红楼聆梦")
    }
    
    private var filteredChapters: [GroupedChapter] {
        if searchText.isEmpty {
            return groupedChapters
        } else {
            let lowercasedSearchText = searchText.lowercased()
            
            return groupedChapters.filter { chapter in
                // Search by chapter number
                String(chapter.chapterNumber).contains(lowercasedSearchText) ||
                // Search by chapter title (case-insensitive)
                chapter.displayTitle.lowercased().contains(lowercasedSearchText)
            }
        }
    }
}

#Preview {
    ContentView()
}