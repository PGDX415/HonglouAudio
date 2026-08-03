//
//  NotesManager.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/3.
//

import Foundation
import Combine

struct Note: Codable, Identifiable, Equatable {
    let id: UUID
    let chapterNumber: Int
    let paragraphIndex: Int
    var content: String
    let createdAt: Date
    var updatedAt: Date

    init(chapterNumber: Int, paragraphIndex: Int, content: String) {
        self.id = UUID()
        self.chapterNumber = chapterNumber
        self.paragraphIndex = paragraphIndex
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

final class NotesManager: ObservableObject {
    static let shared = NotesManager()

    @Published var notes: [Note] = []

    private let storageKey = "paragraph_notes"

    init() {
        loadNotes()
    }

    // MARK: - CRUD

    func notesFor(chapterNumber: Int, paragraphIndex: Int) -> [Note] {
        notes.filter { $0.chapterNumber == chapterNumber && $0.paragraphIndex == paragraphIndex }
    }

    func hasNotes(chapterNumber: Int, paragraphIndex: Int) -> Bool {
        notes.contains { $0.chapterNumber == chapterNumber && $0.paragraphIndex == paragraphIndex }
    }

    func addNote(chapterNumber: Int, paragraphIndex: Int, content: String) {
        let note = Note(chapterNumber: chapterNumber, paragraphIndex: paragraphIndex, content: content)
        notes.append(note)
        saveNotes()
    }

    func updateNote(_ note: Note, content: String) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].content = content
        notes[index].updatedAt = Date()
        saveNotes()
    }

    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }

    func deleteNotesForParagraph(chapterNumber: Int, paragraphIndex: Int) {
        notes.removeAll { $0.chapterNumber == chapterNumber && $0.paragraphIndex == paragraphIndex }
        saveNotes()
    }

    // MARK: - Persistence

    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Note].self, from: data) else { return }
        notes = decoded
    }

    private func saveNotes() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
