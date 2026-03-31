//
//  FavoritesManager.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/31.
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favoriteChapters"
    
    @Published var favoriteChapterNumbers: Set<Int> {
        didSet {
            // Save to UserDefaults whenever favorites change
            userDefaults.set(Array(favoriteChapterNumbers), forKey: favoritesKey)
        }
    }
    
    init() {
        // Load favorites from UserDefaults
        if let savedFavorites = userDefaults.array(forKey: favoritesKey) as? [Int] {
            favoriteChapterNumbers = Set(savedFavorites)
        } else {
            favoriteChapterNumbers = Set()
        }
    }
    
    func toggleFavorite(_ chapterNumber: Int) {
        if favoriteChapterNumbers.contains(chapterNumber) {
            favoriteChapterNumbers.remove(chapterNumber)
        } else {
            favoriteChapterNumbers.insert(chapterNumber)
        }
    }
    
    func isFavorite(_ chapterNumber: Int) -> Bool {
        return favoriteChapterNumbers.contains(chapterNumber)
    }
}