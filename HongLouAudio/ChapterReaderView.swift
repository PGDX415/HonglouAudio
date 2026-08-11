//
//  ChapterReaderView.swift
//  HongLouAudio
//

import SwiftUI

struct ChapterReaderView: View {
    let chapter: Chapter
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var notesManager = NotesManager.shared
    @State private var showAnnotations = false
    @State private var selectedItem: GlossaryItem? = nil
    @State private var editingNoteIndex: Int? = nil
    @State private var noteText: String = ""
    @State private var showNoteEditor = false

    private var paragraphs: [String] {
        chapter.chapterText
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                    VStack(alignment: .leading, spacing: 6) {
                        // Paragraph + note button
                        HStack(alignment: .top, spacing: 4) {
                            if showAnnotations {
                                annotatedText(paragraph)
                            } else {
                                Text(paragraph)
                                    .font(.system(size: 18))
                                    .foregroundColor(theme.primaryText)
                                    .lineSpacing(8)
                                    .multilineTextAlignment(.leading)
                            }

                            // Note toggle button
                            Button(action: {
                                editingNoteIndex = index
                                let existing = notesManager.notesFor(chapterNumber: chapter.number, paragraphIndex: index)
                                noteText = existing.first?.content ?? ""
                                showNoteEditor = true
                            }) {
                                Image(systemName: notesManager.hasNotes(chapterNumber: chapter.number, paragraphIndex: index)
                                    ? "note.text" : "note.text.badge.plus")
                                    .font(.system(size: 12))
                                    .foregroundColor(notesManager.hasNotes(chapterNumber: chapter.number, paragraphIndex: index)
                                        ? theme.accentRed : theme.tertiaryText.opacity(0.4))
                                    .padding(.top, 3)
                            }
                        }

                        // Show existing notes inline
                        let existingNotes = notesManager.notesFor(chapterNumber: chapter.number, paragraphIndex: index)
                        if !existingNotes.isEmpty {
                            ForEach(existingNotes) { note in
                                HStack(alignment: .top) {
                                    Rectangle()
                                        .fill(theme.accentRed.opacity(0.4))
                                        .frame(width: 3)
                                        .cornerRadius(1.5)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(note.content)
                                            .font(.system(size: 13, design: .serif))
                                            .foregroundColor(theme.secondaryText)
                                            .lineSpacing(4)
                                            .lineLimit(5)

                                        Text(note.createdAt, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(theme.tertiaryText)
                                    }

                                    Spacer()
                                }
                                .padding(10)
                                .background(theme.cardBackground)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            theme.readingBackground
                .ignoresSafeArea()
        )
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAnnotations.toggle() }) {
                    Image(systemName: "text.magnifyingglass")
                        .foregroundColor(showAnnotations ? theme.accentRed : theme.secondaryText)
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            glossaryDetailSheet(item)
        }
        .sheet(isPresented: $showNoteEditor) {
            noteEditorSheet
        }
    }

    // MARK: - Annotated Text Rendering

    @ViewBuilder
    private func annotatedText(_ text: String) -> some View {
        let matches = findMatches(in: text)
        if matches.isEmpty {
            Text(text)
                .font(.system(size: 18))
                .foregroundColor(theme.primaryText)
                .lineSpacing(8)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                segmentedHighlightedText(text, matches: matches)
                    .font(.system(size: 18))
                    .lineSpacing(8)

                // Tappable glossary terms found in this paragraph
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(matches.enumerated()), id: \.offset) { _, pair in
                            let (item, _) = pair
                            Button(action: { selectedItem = item }) {
                                Text(item.term)
                                    .font(.caption2)
                                    .foregroundColor(theme.accentRed)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(theme.accentRed.opacity(0.08))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
    }

    private func findMatches(in text: String) -> [(GlossaryItem, Range<String.Index>)] {
        GlossaryStore.findMatches(in: text).sorted { $0.1.lowerBound < $1.1.lowerBound }
    }

    private func segmentedHighlightedText(_ text: String, matches: [(GlossaryItem, Range<String.Index>)]) -> Text {
        var attributed = AttributedString(text)
        attributed.foregroundColor = UIColor(theme.primaryText)

        for (_, range) in matches {
            guard let start = AttributedString.Index(range.lowerBound, within: attributed),
                  let end = AttributedString.Index(range.upperBound, within: attributed) else { continue }
            attributed[start..<end].foregroundColor = UIColor(theme.accentRed)
            attributed[start..<end].underlineStyle = .single
        }

        return Text(attributed)
    }

    // MARK: - Glossary Detail Sheet

    private func glossaryDetailSheet(_ item: GlossaryItem) -> some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Term
                    Text(item.term)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(theme.primaryText)

                    // Pinyin
                    Text(item.pinyin)
                        .font(.system(size: 15, design: .serif))
                        .foregroundColor(theme.accentRed)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(theme.accentRed.opacity(0.08))
                        .cornerRadius(6)

                    // Category badge
                    HStack(spacing: 4) {
                        Image(systemName: "tag")
                            .font(.caption2)
                        Text(item.category.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(theme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(theme.buttonBackground)
                    .cornerRadius(8)

                    Divider()
                        .background(theme.divider)

                    // Explanation
                    Text(item.explanation)
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(theme.secondaryText)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .presentationDetents([.medium, .large])
    }

    // MARK: - Note Editor Sheet

    private var noteEditorSheet: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("取消") {
                    showNoteEditor = false
                }
                .foregroundColor(theme.secondaryText)

                Spacer()

                Text("段落批注")
                    .font(.headline)
                    .foregroundColor(theme.primaryText)

                Spacer()

                Button("保存") {
                    guard let idx = editingNoteIndex, !noteText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    let existing = notesManager.notesFor(chapterNumber: chapter.number, paragraphIndex: idx)
                    if let note = existing.first {
                        notesManager.updateNote(note, content: noteText.trimmingCharacters(in: .whitespaces))
                    } else {
                        notesManager.addNote(chapterNumber: chapter.number, paragraphIndex: idx, content: noteText.trimmingCharacters(in: .whitespaces))
                    }
                    showNoteEditor = false
                }
                .foregroundColor(noteText.trimmingCharacters(in: .whitespaces).isEmpty ? theme.tertiaryText : theme.accentRed)
                .disabled(noteText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()
                .background(theme.divider)

            // Paragraph preview
            if let idx = editingNoteIndex, idx < paragraphs.count {
                Text(paragraphs[idx])
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(theme.tertiaryText)
                    .lineLimit(4)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(theme.cardBackground)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            }

            // Note text editor
            TextEditor(text: $noteText)
                .font(.system(size: 16, design: .serif))
                .foregroundColor(theme.primaryText)
                .scrollContentBackground(.hidden)
                .background(theme.readingBackground)
                .cornerRadius(8)
                .padding(16)
                .frame(minHeight: 160)

            // Delete button (only if note exists)
            if let idx = editingNoteIndex, notesManager.hasNotes(chapterNumber: chapter.number, paragraphIndex: idx) {
                Button(role: .destructive) {
                    notesManager.deleteNotesForParagraph(chapterNumber: chapter.number, paragraphIndex: idx)
                    showNoteEditor = false
                } label: {
                    Label("删除批注", systemImage: "trash")
                        .font(.caption)
                }
                .padding(.bottom, 16)
            }

            Spacer()
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    NavigationStack {
        ChapterReaderView(chapter: Chapter(
            number: 1,
            title: "第一回 上",
            audioFileName: "",
            summary: "",
            textFileName: "chapter_01_shang.txt",
            season: 1,
            paragraphTimestamps: nil
        ))
    }
}
