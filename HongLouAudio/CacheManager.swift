//
//  CacheManager.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/3.
//

import Foundation
import Combine

final class CacheManager: ObservableObject {
    static let shared = CacheManager()

    @Published var isLoading = false

    // MARK: - Size Calculation

    /// App bundle total size (audio + text resources)
    var bundleSize: Int64 {
        guard let bundlePath = Bundle.main.resourcePath else { return 0 }
        return directorySize(at: bundlePath)
    }

    /// Caches directory size (system temp files, if any)
    var cachesSize: Int64 {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let path = paths.first else { return 0 }
        return directorySize(at: path)
    }

    /// UserDefaults data size (bookmarks + progress + favorites + settings)
    var dataSize: Int64 {
        var total: Int64 = 0
        let defaults = UserDefaults.standard
        let dict = defaults.dictionaryRepresentation()

        for (key, value) in dict {
            if key.hasPrefix("bookmarks_") {
                // Bookmarks are stored as Data
                if let data = value as? Data {
                    total += Int64(data.count)
                }
            } else if key.hasPrefix("progress_") {
                // Progress values are stored as Double
                total += 8
            }
        }

        // favorites key
        if let favData = defaults.data(forKey: "favoriteChapters") {
            total += Int64(favData.count)
        }

        return total
    }

    /// Total app footprint
    var totalSize: Int64 {
        bundleSize + cachesSize + dataSize
    }

    // MARK: - Clear Actions

    func clearProgress(completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            let defaults = UserDefaults.standard
            let dict = defaults.dictionaryRepresentation()
            for key in dict.keys where key.hasPrefix("progress_") {
                defaults.removeObject(forKey: key)
            }
            defaults.synchronize()
            DispatchQueue.main.async { completion() }
        }
    }

    func clearBookmarks(completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            let defaults = UserDefaults.standard
            let dict = defaults.dictionaryRepresentation()
            for key in dict.keys where key.hasPrefix("bookmarks_") {
                defaults.removeObject(forKey: key)
            }
            defaults.synchronize()
            DispatchQueue.main.async { completion() }
        }
    }

    func clearCaches(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            if let cachePath = paths.first {
                let fm = FileManager.default
                if let contents = try? fm.contentsOfDirectory(atPath: cachePath) {
                    for item in contents {
                        try? fm.removeItem(atPath: (cachePath as NSString).appendingPathComponent(item))
                    }
                }
            }

            // Also clear tmp directory
            let tmpPath = NSTemporaryDirectory()
            let fm = FileManager.default
            if let contents = try? fm.contentsOfDirectory(atPath: tmpPath) {
                for item in contents {
                    try? fm.removeItem(atPath: (tmpPath as NSString).appendingPathComponent(item))
                }
            }

            DispatchQueue.main.async { completion() }
        }
    }

    func resetAllData(completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            let defaults = UserDefaults.standard
            let dict = defaults.dictionaryRepresentation()

            // Remove only app-specific data, keep system keys and theme/font settings
            let preserveKeys: Set<String> = ["isDarkMode", "textFontSize",
                                              "AppleLanguages", "AppleLocale",
                                              "NSLanguages", "AddingEmojiKeybordHandled"]
            for key in dict.keys {
                if !preserveKeys.contains(key) {
                    defaults.removeObject(forKey: key)
                }
            }
            defaults.synchronize()

            // Clear caches too
            let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            if let cachePath = paths.first {
                let fm = FileManager.default
                if let contents = try? fm.contentsOfDirectory(atPath: cachePath) {
                    for item in contents {
                        try? fm.removeItem(atPath: (cachePath as NSString).appendingPathComponent(item))
                    }
                }
            }

            DispatchQueue.main.async { completion() }
        }
    }

    // MARK: - Helpers

    private func directorySize(at path: String) -> Int64 {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(atPath: path) else { return 0 }
        var size: Int64 = 0
        for case let file as String in enumerator {
            let fullPath = (path as NSString).appendingPathComponent(file)
            if let attrs = try? fm.attributesOfItem(atPath: fullPath),
               let fileSize = attrs[.size] as? Int64 {
                size += fileSize
            }
        }
        return size
    }
}

// MARK: - Byte Formatter

extension Int64 {
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}
