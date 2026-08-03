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
        Group {
            if searchText.isEmpty {
                chapterList
            } else {
                searchResultsList
            }
        }
        .searchable(text: $searchText, prompt: "搜索回目、标题或正文...")
        .onAppear {
            let allChapters = ChapterLoader.loadChapters()
            groupedChapters = allChapters.groupByHui()
        }
        .background(
            theme.pageBackground
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

    // MARK: - Chapter List (no search)

    private var chapterList: some View {
        List(filteredChapters) { groupedChapter in
            NavigationLink(destination: ChapterDetailView(groupedChapter: groupedChapter, favoritesManager: favoritesManager)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(groupedChapter.chapterNumber)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(theme.accentRed)
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

                            if let firstPartSummary = groupedChapter.parts.first?.summary {
                                Text(firstPartSummary)
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryText)
                                    .lineLimit(2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

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
            .listRowBackground(theme.cardBackground)
        }
        .listStyle(PlainListStyle())
    }

    // MARK: - Search Results List

    private var searchResultsList: some View {
        List {
            if fullTextSearchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundColor(theme.secondaryText)
                    Text("未找到匹配内容")
                        .font(.body)
                        .foregroundColor(theme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(theme.pageBackground)
            } else {
                ForEach(fullTextSearchResults) { result in
                    NavigationLink(destination: AudioPlayerView(chapter: result.chapter)) {
                        VStack(alignment: .leading, spacing: 6) {
                            // Chapter badge + title
                            HStack(spacing: 8) {
                                Text("第\(result.chapterNumber)回")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(theme.accentRed)
                                    .cornerRadius(4)

                                Text(result.chapter.title)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(theme.primaryText)
                                    .lineLimit(1)
                            }

                            // Highlighted snippet
                            highlightedSnippet(fullText: result.matchText, keyword: searchText)
                                .font(.subheadline)
                                .lineLimit(3)
                        }
                        .padding(.vertical, 6)
                    }
                    .listRowBackground(theme.cardBackground)
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    // MARK: - Snippet Highlighting

    private func highlightedSnippet(fullText: String, keyword: String) -> Text {
        let lowerFull = fullText.lowercased()
        let lowerKey = keyword.lowercased()

        guard let range = lowerFull.range(of: lowerKey) else {
            return Text(fullText)
        }

        // Extract context: up to 30 chars before and after the match
        let snippetStart = lowerFull.distance(from: lowerFull.startIndex, to: range.lowerBound)
        let snippetEnd = lowerFull.distance(from: lowerFull.startIndex, to: range.upperBound)

        let totalChars = fullText.count
        let contextBefore = max(0, snippetStart - 12)
        let contextAfter = min(totalChars, snippetEnd + 40)

        let startIdx = fullText.index(fullText.startIndex, offsetBy: contextBefore)
        let matchStartIdx = fullText.index(fullText.startIndex, offsetBy: snippetStart)
        let matchEndIdx = fullText.index(fullText.startIndex, offsetBy: snippetEnd)
        let endIdx = fullText.index(fullText.startIndex, offsetBy: contextAfter)

        let beforeText = String(fullText[startIdx..<matchStartIdx])
        let matchText = String(fullText[matchStartIdx..<matchEndIdx])
        let afterText = String(fullText[matchEndIdx..<endIdx])

        var result = Text(contextBefore > 0 ? "…" : "")
        result = result + Text(beforeText)
        result = result + Text(matchText)
            .foregroundColor(theme.accentRed)
            .fontWeight(.bold)
        result = result + Text(afterText)
        result = result + Text(contextAfter < totalChars ? "…" : "")

        return result
    }

    private var filteredChapters: [GroupedChapter] {
        if searchText.isEmpty {
            return groupedChapters
        } else {
            let lowercasedSearchText = searchText.lowercased()

            return groupedChapters.filter { chapter in
                String(chapter.chapterNumber).contains(lowercasedSearchText) ||
                chapter.displayTitle.lowercased().contains(lowercasedSearchText)
            }
        }
    }

    // MARK: - Full-text Search

    private var fullTextSearchResults: [TextSearchResult] {
        guard searchText.count >= 1 else { return [] }
        let keyword = searchText.lowercased()
        var results: [TextSearchResult] = []
        var seenChapterNumbers = Set<Int>()

        // Search titles first (faster, shown at top)
        for group in groupedChapters {
            if group.displayTitle.lowercased().contains(keyword) {
                for chapter in group.parts {
                    results.append(TextSearchResult(
                        chapter: chapter,
                        chapterNumber: group.chapterNumber,
                        matchText: chapter.summary,
                        keyword: searchText
                    ))
                }
                seenChapterNumbers.insert(group.chapterNumber)
            }
        }

        // Search chapter text
        for group in groupedChapters {
            if seenChapterNumbers.contains(group.chapterNumber) { continue }
            for chapter in group.parts {
                guard !chapter.chapterText.isEmpty else { continue }
                let paragraphs = chapter.chapterText
                    .components(separatedBy: "\n\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                for paragraph in paragraphs {
                    if paragraph.lowercased().contains(keyword) {
                        results.append(TextSearchResult(
                            chapter: chapter,
                            chapterNumber: group.chapterNumber,
                            matchText: paragraph,
                            keyword: searchText
                        ))
                        seenChapterNumbers.insert(group.chapterNumber)
                        break // one result per chapter is sufficient
                    }
                }
            }
        }

        return results
    }
}

// MARK: - Search Result Model

struct TextSearchResult: Identifiable {
    let id = UUID()
    let chapter: Chapter
    let chapterNumber: Int
    let matchText: String
    let keyword: String
}

#Preview {
    ContentView()
}