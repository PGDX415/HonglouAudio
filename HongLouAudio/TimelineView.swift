//
//  TimelineView.swift
//  HongLouAudio
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var selectedChapter: Chapter? = nil

    private let chapters: [Chapter]
    private let eventsByChapter: [Int: [TimelineEvent]]
    private let sortedChapterNumbers: [Int]

    init() {
        let allChapters = ChapterLoader.loadChapters()
        self.chapters = allChapters
        self.eventsByChapter = TimelineStore.allEvents
        self.sortedChapterNumbers = TimelineStore.chapterNumbers
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(sortedChapterNumbers, id: \.self) { chapterNum in
                    chapterSection(chapterNum)
                }
            }
            .padding(.vertical, 20)
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .navigationTitle("大事年表")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedChapter) { chapter in
            AudioPlayerView(chapter: chapter)
        }
    }

    // MARK: - Chapter Section

    private func chapterSection(_ chapterNum: Int) -> some View {
        let events = eventsByChapter[chapterNum] ?? []
        let chapterTitle = chapterTitleFor(chapterNum)

        return VStack(alignment: .leading, spacing: 0) {
            // Chapter header
            HStack(spacing: 10) {
                // Timeline dot
                Circle()
                    .fill(theme.accentRed)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(theme.accentRed.opacity(0.3), lineWidth: 4)
                    )

                // Chapter number + title
                VStack(alignment: .leading, spacing: 2) {
                    Text("第\(chapterNum)回")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.accentRed)
                    if !chapterTitle.isEmpty {
                        Text(chapterTitle)
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(theme.tertiaryText)
                            .lineLimit(2)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 6)

            // Events
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                eventRow(event, isLast: index == events.count - 1)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Event Row

    private func eventRow(_ event: TimelineEvent, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // Timeline line + dot
            VStack(spacing: 0) {
                if isLast {
                    Circle()
                        .fill(theme.accentRed.opacity(0.5))
                        .frame(width: 8, height: 8)
                } else {
                    Rectangle()
                        .fill(theme.accentRed.opacity(0.3))
                        .frame(width: 2)
                    Circle()
                        .fill(theme.accentRed.opacity(0.5))
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(theme.accentRed.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 14)
            .padding(.top, 4)

            // Event card
            Button {
                if let firstPart = chapters.first(where: { titleBelongsToChapter($0.title, chapterNum: event.chapterNumber) }) {
                    selectedChapter = firstPart
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(theme.primaryText)
                        .lineLimit(2)

                    Text(event.detail)
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(theme.secondaryText)
                        .lineSpacing(4)
                        .lineLimit(5)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.cardBackground)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func chapterTitleFor(_ num: Int) -> String {
        let parts = chapters.filter { parseChapterNumber(from: $0.title) == num }
        guard let first = parts.first else { return "" }
        var title = first.title
        for suffix in [" 上", " 中", " 下"] {
            if title.hasSuffix(suffix) {
                title = String(title.dropLast(suffix.count))
            }
        }
        if let di = title.firstIndex(of: "第"),
           let hui = title.firstIndex(of: "回"), di < hui {
            let afterHui = title.index(after: hui)
            if afterHui <= title.endIndex {
                title = String(title[afterHui...]).trimmingCharacters(in: .whitespaces)
            }
        }
        return title
    }

    private func titleBelongsToChapter(_ title: String, chapterNum: Int) -> Bool {
        parseChapterNumber(from: title) == chapterNum
    }

    private func parseChapterNumber(from title: String) -> Int {
        guard let di = title.firstIndex(of: "第"),
              let hui = title.firstIndex(of: "回"), di < hui else { return 0 }
        let numStr = String(title[title.index(after: di)..<hui])
        return chineseToInt(numStr)
    }

    private let cnDigits: [String: Int] = [
        "\u{4e00}": 1, "\u{4e8c}": 2, "\u{4e09}": 3, "\u{56db}": 4, "\u{4e94}": 5,
        "\u{516d}": 6, "\u{4e03}": 7, "\u{516b}": 8, "\u{4e5d}": 9, "\u{5341}": 10
    ]

    /// Convert Chinese numerals: "一"→1, "十四"→14, "三十"→30, "五十九"→59
    private func chineseToInt(_ s: String) -> Int {
        let chars = s.map { String($0) }
        switch chars.count {
        case 1: return cnDigits[chars[0]] ?? 0
        case 2:
            if chars[0] == "\u{5341}" { return 10 + (cnDigits[chars[1]] ?? 0) }
            if chars[1] == "\u{5341}" { return (cnDigits[chars[0]] ?? 0) * 10 }
            return 0
        case 3:
            return (cnDigits[chars[0]] ?? 0) * 10 + (cnDigits[chars[2]] ?? 0)
        default: return 0
        }
    }
}

#Preview {
    NavigationStack {
        TimelineView()
    }
}
