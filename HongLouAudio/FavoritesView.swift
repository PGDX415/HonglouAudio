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
    @State private var selectedGC: GroupedChapter? = nil

    var body: some View {
        ZStack {
            List(favoritedChapters) { groupedChapter in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(groupedChapter.chapterNumber)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(theme.accentRed)
                            .clipShape(Circle())

                        Text(groupedChapter.displayTitle)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(theme.primaryText)

                        Spacer()

                        // Favorite indicator (always filled since these are favorites)
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }

                    // Show summary of first part as representative summary
                    if let firstPartSummary = groupedChapter.parts.first?.summary {
                        Text(firstPartSummary)
                            .font(.caption)
                            .foregroundColor(theme.secondaryText)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedGC = groupedChapter
                }
                .listRowBackground(theme.cardBackground)
            }
            .navigationTitle("收藏")
            .onAppear {
                let allChapters = ChapterLoader.loadChapters()
                groupedChapters = allChapters.groupByHui()
            }
            .listStyle(.plain)
            .background(
                theme.pageBackground
                    .ignoresSafeArea()
            )

            // Hidden NavigationLink outside List (no chevron)
            if let gc = selectedGC {
                NavigationLink(
                    destination: ChapterDetailView(groupedChapter: gc, favoritesManager: favoritesManager),
                    isActive: Binding(
                        get: { selectedGC != nil },
                        set: { if !$0 { selectedGC = nil } }
                    )
                ) { EmptyView() }
                .hidden()
            }
        }
    }
    
    private var favoritedChapters: [GroupedChapter] {
        return groupedChapters.filter { favoritesManager.isFavorite($0.chapterNumber) }
    }
}

#Preview {
    FavoritesView()
}