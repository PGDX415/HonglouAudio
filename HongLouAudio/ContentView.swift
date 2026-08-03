//
//  ContentView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/30.
//

import SwiftUI

struct ContentView: View {
    @State private var groupedChapters: [GroupedChapter] = []
    @ObservedObject private var theme = ThemeManager.shared
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var searchText = ""
    @State private var showPlayAll = false
    @State private var playAllStartChapter: Chapter?

    /// Flatten all parts into a single sequential list for "全部播放"
    private var allChaptersFlat: [Chapter] {
        groupedChapters.flatMap { $0.parts.sorted { $0.number < $1.number } }
    }
    
    var body: some View {
        List(filteredChapters) { groupedChapter in
            NavigationLink(destination: ChapterDetailView(groupedChapter: groupedChapter, favoritesManager: favoritesManager)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(groupedChapter.chapterNumber)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(theme.accentRed) // Classical red
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            VStack(alignment: .leading, spacing: 0) {
                                if groupedChapter.titleLines.count >= 3 {
                                    HStack(alignment: .center, spacing: 6) {
                                        Text(groupedChapter.titleLines[0])
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(theme.tertiaryText)
                                            .fixedSize()
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(groupedChapter.titleLines[1])
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(theme.primaryText)
                                            Text(groupedChapter.titleLines[2])
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(theme.primaryText)
                                        }
                                    }
                                } else {
                                    Text(groupedChapter.displayTitle)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(theme.primaryText)
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)

                            // Show summary of first part as representative summary
                            if let firstPartSummary = groupedChapter.parts.first?.summary {
                                Text(firstPartSummary)
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryText) // Warm brown
                                    .lineLimit(2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

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
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(theme.cardBackground) // Antique paper color
        }
        .searchable(text: $searchText, prompt: "搜索章回号或标题...")
        .onAppear {
            let allChapters = ChapterLoader.loadChapters()
            groupedChapters = allChapters.groupByHui()
        }
        .listStyle(PlainListStyle())
        .background(
            theme.pageBackground // Soft antique paper background
                .ignoresSafeArea()
        )
        .navigationTitle("红楼聆梦")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        let allChapters = allChaptersFlat
                        guard let first = allChapters.first else { return }
                        AudioManager.shared.configurePlaylist(allChapters, startIndex: 0)
                        AudioManager.shared.playMode = .sequential
                        playAllStartChapter = first
                        showPlayAll = true
                    }) {
                        Label("全部播放", systemImage: "play.fill")
                    }

                    ForEach(groupedChapters.filter { !$0.parts.isEmpty }) { gc in
                        Button(action: {
                            let allChapters = allChaptersFlat
                            guard let firstPart = gc.parts.first,
                                  let startIdx = allChapters.firstIndex(where: { $0.number == firstPart.number }) else { return }
                            AudioManager.shared.configurePlaylist(allChapters, startIndex: startIdx)
                            AudioManager.shared.playMode = .sequential
                            playAllStartChapter = firstPart
                            showPlayAll = true
                        }) {
                            Label("从第\(gc.chapterNumber)回开始", systemImage: "forward.fill")
                        }
                    }
                } label: {
                    Image(systemName: "list.bullet")
                        .foregroundColor(theme.accentRed)
                }
            }
        }
        .navigationDestination(isPresented: $showPlayAll) {
            if let chapter = playAllStartChapter {
                AudioPlayerView(chapter: chapter)
            }
        }
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