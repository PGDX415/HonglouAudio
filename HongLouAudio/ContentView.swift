//
//  ContentView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/30.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @State private var groupedChapters: [GroupedChapter] = []
    @ObservedObject private var theme = ThemeManager.shared
    @State private var showSearch = false
    @State private var progressData: [Int: Double] = [:] // chapterNumber -> progress proportion
    @State private var navPath = NavigationPath()
    @State private var selectedSeasonID: Int? = nil // nil = 全部
    @State private var selectedPartID: Int = 1      // 1 = 上部, 2 = 下部

    /// Flatten all parts into a single ordered list
    private var allChaptersFlat: [Chapter] {
        groupedChapters.flatMap { $0.parts.sorted { $0.number < $1.number } }
    }

    /// Chapters filtered by selected part + season
    private var filteredGroupedChapters: [GroupedChapter] {
        let partSeasonIDs = Set(currentPartSeasons.map { $0.id })
        // Filter by current part first
        var result = groupedChapters.filter { gc in
            guard let chSeason = Season.season(for: gc.chapterNumber) else { return false }
            return partSeasonIDs.contains(chSeason.id)
        }
        // Then filter by selected season if any
        if let seasonID = selectedSeasonID,
           let season = Season.allSeasons.first(where: { $0.id == seasonID }) {
            result = result.filter { season.chapterRange.contains($0.chapterNumber) }
        }
        return result
    }

    /// Seasons for the currently selected part
    private var currentPartSeasons: [Season] {
        Season.seasons(for: selectedPartID)
    }

    /// Navigation title with part + seasonal indicator
    private var navigationTitle: String {
        let currentPart = Part.allParts.first { $0.id == selectedPartID }
        let partEmoji = currentPart?.emoji ?? ""
        if let seasonID = selectedSeasonID,
           let season = currentPartSeasons.first(where: { $0.id == seasonID }) {
            return "红楼聆梦 \(partEmoji)\(season.coverEmoji)"
        }
        return "红楼聆梦 \(partEmoji)"
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            List {
                // Season picker
                Section {
                    seasonPickerView
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                // Daily quote banner
                Section {
                    dailyQuoteBanner
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                ForEach(filteredGroupedChapters, id: \.id) { groupedChapter in
                    Button {
                        navPath.append(groupedChapter)
                    } label: {
                        chapterRowContent(groupedChapter)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
        .onAppear {
            let allChapters = ChapterLoader.loadChapters()
            groupedChapters = allChapters.groupByHui()
            refreshProgress()
        }
        .onReceive(NotificationCenter.default.publisher(for: .progressUpdated)) { _ in
            refreshProgress()
        }
        .background(
            theme.pageBackground
                .ignoresSafeArea()
        )
        .navigationTitle(navigationTitle)
        .navigationDestination(for: GroupedChapter.self) { gc in
            ChapterDetailView(groupedChapter: gc, favoritesManager: favoritesManager)
        }
        .navigationDestination(for: Chapter.self) { chapter in
            AudioPlayerView(chapter: chapter)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.accentRed)
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchSheetView(groupedChapters: filteredGroupedChapters) { chapter in
                showSearch = false
                navPath.append(chapter)
            }
        }
        }
    }

    // MARK: - Season Picker

    private var seasonPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Part toggle: 上部 / 下部
            HStack(spacing: 0) {
                ForEach(Part.allParts) { part in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPartID = part.id
                            selectedSeasonID = nil
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(part.emoji)
                                .font(.system(size: 14))
                            Text(part.shortName)
                                .font(.system(size: 13, weight: selectedPartID == part.id ? .bold : .medium))
                        }
                        .foregroundColor(selectedPartID == part.id ? .white : theme.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedPartID == part.id
                                ? theme.accentRed
                                : Color(.systemGray6)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Season chips for current part
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(currentPartSeasons) { season in
                        SeasonChip(
                            label: season.shortTitle,
                            subtitle: "第\(season.chapterRange.lowerBound)-\(season.chapterRange.upperBound)回",
                            isSelected: selectedSeasonID == season.id,
                            accentColor: theme.accentRed
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                // Toggle: tap again to deselect (show all in this part)
                                selectedSeasonID = (selectedSeasonID == season.id) ? nil : season.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }

            // Season banner when a season is selected
            if let seasonID = selectedSeasonID,
               let season = currentPartSeasons.first(where: { $0.id == seasonID }) {
                let chaptersForSeason = allChaptersFlat.filter { $0.season == seasonID }
                let completedInSeason = seasonProgress(for: season)
                SeasonBanner(
                    season: season,
                    theme: theme,
                    seasonChapters: chaptersForSeason,
                    completedChapterCount: completedInSeason
                )
                    .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Daily Quote

    private var dailyQuoteBanner: some View {
        let quote = DailyQuoteStore.todayQuote()
        return VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 16))
                        .foregroundColor(theme.accentRed.opacity(0.3))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(quote.text)
                        .font(.system(size: 15, design: .serif))
                        .foregroundColor(theme.primaryText)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(theme.accentRed.opacity(0.3))
                            .frame(width: 16, height: 1)

                        Text(quote.source)
                            .font(.system(size: 11, design: .serif))
                            .foregroundColor(theme.tertiaryText)
                    }
                }

                Spacer()
            }
            .padding(14)

            Divider()
                .background(theme.divider)
        }
        .background(theme.cardBackground)
    }

    // MARK: - Chapter Row Content

    @ViewBuilder
    private func chapterRowContent(_ groupedChapter: GroupedChapter) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // Chapter number with download ring
            ZStack {
                // Fixed-size number badge for all chapters
                Text("\(groupedChapter.chapterNumber)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(theme.accentRed)
                    .clipShape(Circle())

                // Download progress ring (only visible when remote URL configured)
                chapterDownloadOverlay(groupedChapter)
            }

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

                // Reading progress indicator
                let progress = chapterProgress(for: groupedChapter)
                if progress > 0 {
                    HStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(theme.divider)
                                    .frame(height: 3)
                                Capsule()
                                    .fill(progress >= 0.95 ? Color.green.opacity(0.7) : theme.accentRed)
                                    .frame(width: geo.size.width * CGFloat(progress), height: 3)
                            }
                        }
                        .frame(height: 3)

                        Text(progress >= 0.95 ? "已听完" : "\(Int(progress * 100))%")
                            .font(.system(size: 10))
                            .foregroundColor(progress >= 0.95 ? .green.opacity(0.7) : theme.accentRed)
                    }
                    .padding(.top, 2)
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
        .padding(.vertical, 4)
    }

    // MARK: - Reading Progress

    private func refreshProgress() {
        let defaults = UserDefaults.standard
        var data: [Int: Double] = [:]
        var completedCount = 0
        for gc in groupedChapters {
            let parts = gc.parts
            var validParts = 0
            let total = parts.reduce(0.0) {
                let val = defaults.double(forKey: "progress_\($1.audioFileName)")
                guard val > 0, val <= 1.0 else { return $0 }
                validParts += 1
                return $0 + val
            }
            if validParts > 0 {
                let avg = total / Double(validParts)
                data[gc.chapterNumber] = avg
                if avg >= 0.95 { completedCount += 1 }
            }
        }
        progressData = data
        ListeningStatsManager.shared.updateCompletedCount(completedCount)
    }

    private func chapterProgress(for groupedChapter: GroupedChapter) -> Double {
        progressData[groupedChapter.chapterNumber] ?? 0
    }

    /// Count completed chapters (>= 95% listened) within a season
    private func seasonProgress(for season: Season) -> Int {
        groupedChapters
            .filter { season.chapterRange.contains($0.chapterNumber) }
            .filter { (progressData[$0.chapterNumber] ?? 0) >= 0.95 }
            .count
    }

    // MARK: - Download Indicators

    /// Shows download status ring around the chapter number.
    /// Only visible when a remote base URL is configured.
    @ViewBuilder
    private func chapterDownloadOverlay(_ groupedChapter: GroupedChapter) -> some View {
        let downloadManager = AudioDownloadManager.shared

        if !downloadManager.remoteBaseURL.isEmpty {
            let parts = groupedChapter.parts
            let total = parts.count
            let downloaded = parts.filter { downloadManager.isDownloaded($0.audioFileName) }.count
            let anyDownloading = parts.contains { downloadManager.activeDownloads.contains($0.audioFileName) }

            if total > 0, downloaded < total {
                Circle()
                    .stroke(
                        anyDownloading ? Color.orange : theme.accentRed.opacity(0.3),
                        lineWidth: 2.5
                    )
                    .frame(width: 44, height: 44)

                if anyDownloading {
                    if let firstDL = parts.first(where: { downloadManager.activeDownloads.contains($0.audioFileName) }),
                       let progress = downloadManager.downloadProgress[firstDL.audioFileName] {
                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(Color.orange, lineWidth: 2.5)
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.3), value: progress)
                    }
                }
            } else if downloaded == total, total > 0 {
                Circle()
                    .stroke(Color.green.opacity(0.5), lineWidth: 2.5)
                    .frame(width: 44, height: 44)
            }
        }
    }
}

// MARK: - Search Sheet

struct SearchSheetView: View {
    let groupedChapters: [GroupedChapter]
    let onSelect: (Chapter) -> Void

    @ObservedObject private var theme = ThemeManager.shared
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var searchResults: [TextSearchResult] {
        guard searchText.count >= 1 else { return [] }
        let keyword = searchText.lowercased()
        var results: [TextSearchResult] = []
        var seen = Set<Int>()

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
                seen.insert(group.chapterNumber)
            }
        }

        for group in groupedChapters {
            if seen.contains(group.chapterNumber) { continue }
            for chapter in group.parts {
                guard !chapter.chapterText.isEmpty else { continue }
                let paragraphs = chapter.chapterText
                    .components(separatedBy: "\n")
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
                        seen.insert(group.chapterNumber)
                        break
                    }
                }
            }
        }
        return results
    }

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(theme.secondaryText)
                        Text("搜索回目、标题或正文")
                            .font(.body)
                            .foregroundColor(theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.pageBackground)
                } else if searchResults.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(theme.secondaryText)
                        Text("未找到匹配内容")
                            .font(.body)
                            .foregroundColor(theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.pageBackground)
                } else {
                    List {
                        ForEach(searchResults) { result in
                            Button {
                                dismiss()
                                onSelect(result.chapter)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
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
                                    highlightedText(fullText: result.matchText, keyword: searchText)
                                        .font(.subheadline)
                                        .lineLimit(3)
                                }
                                .padding(.vertical, 6)
                            }
                            .listRowBackground(theme.cardBackground)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "搜索回目、标题或正文...")
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") { dismiss() }
                        .foregroundColor(theme.accentRed)
                }
            }
        }
    }

    private func highlightedText(fullText: String, keyword: String) -> Text {
        let lowerFull = fullText.lowercased()
        let lowerKey = keyword.lowercased()
        guard let range = lowerFull.range(of: lowerKey) else {
            return Text(fullText)
        }
        let start = lowerFull.distance(from: lowerFull.startIndex, to: range.lowerBound)
        let end = lowerFull.distance(from: lowerFull.startIndex, to: range.upperBound)
        let total = fullText.count
        let before = max(0, start - 12)
        let after = min(total, end + 40)

        let sIdx = fullText.index(fullText.startIndex, offsetBy: before)
        let mS = fullText.index(fullText.startIndex, offsetBy: start)
        let mE = fullText.index(fullText.startIndex, offsetBy: end)
        let eIdx = fullText.index(fullText.startIndex, offsetBy: after)

        let prefix = before > 0 ? "…" : ""
        let suffix = after < total ? "…" : ""
        let combined = prefix + String(fullText[sIdx..<mS]) + String(fullText[mS..<mE]) + String(fullText[mE..<eIdx]) + suffix

        var attr = AttributedString(combined)
        if let r = attr.range(of: String(fullText[mS..<mE])) {
            attr[r].foregroundColor = UIColor(theme.accentRed)
            attr[r].font = .systemFont(ofSize: 15, weight: .bold)
        }
        return Text(attr)
    }
}

struct TextSearchResult: Identifiable {
    let id = UUID()
    let chapter: Chapter
    let chapterNumber: Int
    let matchText: String
    let keyword: String
}

// MARK: - Season Chip Component

struct SeasonChip: View {
    let label: String
    let subtitle: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? accentColor : Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Season Banner

struct SeasonBanner: View {
    let season: Season
    let theme: ThemeManager
    @ObservedObject private var downloadManager = AudioDownloadManager.shared
    @State private var isDownloadingSeason = false

    /// All chapter parts for this season (passed from parent)
    var seasonChapters: [Chapter] = []
    /// Number of completed chapters in this season (>= 95% listened)
    var completedChapterCount: Int = 0

    private var totalChapters: Int { season.chapterRange.count }
    private var progressFraction: CGFloat {
        totalChapters > 0 ? CGFloat(completedChapterCount) / CGFloat(totalChapters) : 0
    }

    private var downloadedCount: Int {
        seasonChapters.filter { downloadManager.isDownloaded($0.audioFileName) }.count
    }

    private var totalAudioFiles: Int {
        seasonChapters.count
    }

    private var isFullyDownloaded: Bool {
        totalAudioFiles > 0 && downloadedCount == totalAudioFiles
    }

    private var gradientColors: [Color] {
        switch season.id {
        case 1: return [
            Color(red: 0.45, green: 0.18, blue: 0.10),
            Color(red: 0.65, green: 0.28, blue: 0.18),
            Color(red: 0.55, green: 0.20, blue: 0.12)
        ]
        case 2: return [
            Color(red: 0.20, green: 0.42, blue: 0.30),
            Color(red: 0.25, green: 0.48, blue: 0.35),
            Color(red: 0.32, green: 0.52, blue: 0.38)
        ]
        case 3: return [
            Color(red: 0.52, green: 0.22, blue: 0.18),
            Color(red: 0.60, green: 0.26, blue: 0.22),
            Color(red: 0.48, green: 0.16, blue: 0.14)
        ]
        case 4: return [
            Color(red: 0.18, green: 0.14, blue: 0.38),
            Color(red: 0.22, green: 0.16, blue: 0.42),
            Color(red: 0.15, green: 0.10, blue: 0.35)
        ]
        case 5: return [
            Color(red: 0.55, green: 0.35, blue: 0.12),
            Color(red: 0.62, green: 0.38, blue: 0.15),
            Color(red: 0.48, green: 0.28, blue: 0.08)
        ]
        case 6: return [
            Color(red: 0.42, green: 0.18, blue: 0.22),
            Color(red: 0.48, green: 0.22, blue: 0.26),
            Color(red: 0.35, green: 0.12, blue: 0.18)
        ]
        case 7: return [
            Color(red: 0.22, green: 0.15, blue: 0.18),
            Color(red: 0.28, green: 0.18, blue: 0.22),
            Color(red: 0.18, green: 0.10, blue: 0.15)
        ]
        case 8: return [
            Color(red: 0.15, green: 0.18, blue: 0.28),
            Color(red: 0.18, green: 0.22, blue: 0.32),
            Color(red: 0.10, green: 0.14, blue: 0.25)
        ]
        default: return [theme.accentRed, theme.deepRed]
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Gradient background
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 140, height: 140)
                .offset(x: 40, y: -30)

            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 80, height: 80)
                .offset(x: -70, y: 60)

            // Content
            VStack(alignment: .leading, spacing: 0) {
                // Top row: emoji + download button
                HStack(alignment: .top) {
                    Text(season.coverEmoji)
                        .font(.system(size: 40))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                    Spacer()

                    // Download section
                    if totalAudioFiles > 0 {
                        VStack(alignment: .trailing, spacing: 6) {
                            // Chapter count
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("共 \(season.chapterRange.count) 回")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("第 \(season.chapterRange.lowerBound)－\(season.chapterRange.upperBound) 回")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.5))
                            }

                            // Download button
                            if !isFullyDownloaded {
                                Button(action: {
                                    downloadManager.downloadSeason(season, chapters: seasonChapters)
                                    isDownloadingSeason = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: isDownloadingSeason ? "arrow.down.circle.fill" : "arrow.down.circle")
                                            .font(.system(size: 12))
                                        if downloadedCount > 0 {
                                            Text("\(downloadedCount)/\(totalAudioFiles)")
                                                .font(.system(size: 10, weight: .medium))
                                        } else {
                                            Text("下载本季")
                                                .font(.system(size: 10, weight: .medium))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.2))
                                    )
                                }
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text("已下载")
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                Spacer().frame(height: 10)

                // Season name
                Text(season.name)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)

                // Listening progress
                if completedChapterCount > 0 {
                    Spacer().frame(height: 10)
                    HStack(spacing: 8) {
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 3)
                                Capsule()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: geo.size.width * progressFraction, height: 3)
                            }
                        }
                        .frame(height: 3)

                        Text("已听 \(completedChapterCount)/\(totalChapters) 回")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer().frame(height: 8)

                // Intro paragraph
                Text(season.introText)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 12)

                // Key events tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(season.keyEvents, id: \.self) { event in
                            Text(event)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                )
                        }
                    }
                }
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ContentView(favoritesManager: FavoritesManager())
}