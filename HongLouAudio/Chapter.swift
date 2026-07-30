//
//  Chapter.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/30.
//

import Foundation

struct Chapter: Codable, Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let audioFileName: String
    let summary: String
    let textFileName: String?

    var chapterText: String {
        guard let fileName = textFileName else { return "" }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            return ""
        }
        return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case number = "number"
        case title = "title"
        case audioFileName = "audioFileName"
        case summary = "summary"
        case textFileName = "textFileName"
    }
}

struct ChaptersData: Codable {
    let chapters: [Chapter]
}

struct GroupedChapter: Identifiable {
    let id = UUID()
    let chapterNumber: Int // The actual 回 number (1-60)
    let titlePrefix: String // e.g., "第一回 甄士隐梦幻识通灵 贾雨村风尘怀闺秀"
    let parts: [Chapter] // The individual parts (上, 中, 下)
    
    var displayTitle: String {
        return titlePrefix
    }

    /// Returns the three parts of the title: [chapterLabel, firstClause, secondClause]
    /// e.g., ["第一回", "甄士隐梦幻识通灵", "贾雨村风尘怀闺秀"]
    var titleLines: [String] {
        let parts = titlePrefix.components(separatedBy: " ")
        return parts
    }
}

extension Array where Element == Chapter {
    func groupByHui() -> [GroupedChapter] {
        var groups: [String: [Chapter]] = [:]
        
        for chapter in self {
            // Extract the chapter prefix (everything before " 上", " 中", or " 下")
            var prefix = chapter.title
            if prefix.hasSuffix(" 上") {
                prefix = String(prefix.dropLast(2))
            } else if prefix.hasSuffix(" 中") {
                prefix = String(prefix.dropLast(2))
            } else if prefix.hasSuffix(" 下") {
                prefix = String(prefix.dropLast(2))
            }
            
            // Extract the chapter number from the prefix (e.g., "第一回" -> 1)
            let chapterNumber = extractChapterNumber(from: prefix)
            
            // Use the full prefix as the key to group chapters
            if groups[prefix] == nil {
                groups[prefix] = []
            }
            groups[prefix]?.append(chapter)
        }
        
        // Sort groups by chapter number and create GroupedChapter objects
        let sortedGroups = groups.sorted { (group1, group2) -> Bool in
            let num1 = extractChapterNumber(from: group1.key)
            let num2 = extractChapterNumber(from: group2.key)
            return num1 < num2
        }
        
        return sortedGroups.map { group in
            let chapterNumber = extractChapterNumber(from: group.key)
            return GroupedChapter(
                chapterNumber: chapterNumber,
                titlePrefix: group.key,
                parts: group.value.sorted { $0.number < $1.number }
            )
        }
    }
    
    private func extractChapterNumber(from title: String) -> Int {
        // Extract number from format like "第一回", "第二回", etc.
        let numberWords = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
        
        // Handle special cases for numbers 1-60
        if title.hasPrefix("第一回") { return 1 }
        if title.hasPrefix("第二回") { return 2 }
        if title.hasPrefix("第三回") { return 3 }
        if title.hasPrefix("第四回") { return 4 }
        if title.hasPrefix("第五回") { return 5 }
        if title.hasPrefix("第六回") { return 6 }
        if title.hasPrefix("第七回") { return 7 }
        if title.hasPrefix("第八回") { return 8 }
        if title.hasPrefix("第九回") { return 9 }
        if title.hasPrefix("第十回") { return 10 }
        
        // Handle 11-19
        if title.hasPrefix("第十一回") { return 11 }
        if title.hasPrefix("第十二回") { return 12 }
        if title.hasPrefix("第十三回") { return 13 }
        if title.hasPrefix("第十四回") { return 14 }
        if title.hasPrefix("第十五回") { return 15 }
        if title.hasPrefix("第十六回") { return 16 }
        if title.hasPrefix("第十七回") { return 17 }
        if title.hasPrefix("第十八回") { return 18 }
        if title.hasPrefix("第十九回") { return 19 }
        
        // Handle 20-29
        if title.hasPrefix("第二十回") { return 20 }
        if title.hasPrefix("第二十一回") { return 21 }
        if title.hasPrefix("第二十二回") { return 22 }
        if title.hasPrefix("第二十三回") { return 23 }
        if title.hasPrefix("第二十四回") { return 24 }
        if title.hasPrefix("第二十五回") { return 25 }
        if title.hasPrefix("第二十六回") { return 26 }
        if title.hasPrefix("第二十七回") { return 27 }
        if title.hasPrefix("第二十八回") { return 28 }
        if title.hasPrefix("第二十九回") { return 29 }
        
        // Handle 30-39
        if title.hasPrefix("第三十回") { return 30 }
        if title.hasPrefix("第三十一回") { return 31 }
        if title.hasPrefix("第三十二回") { return 32 }
        if title.hasPrefix("第三十三回") { return 33 }
        if title.hasPrefix("第三十四回") { return 34 }
        if title.hasPrefix("第三十五回") { return 35 }
        if title.hasPrefix("第三十六回") { return 36 }
        if title.hasPrefix("第三十七回") { return 37 }
        if title.hasPrefix("第三十八回") { return 38 }
        if title.hasPrefix("第三十九回") { return 39 }
        
        // Handle 40-49
        if title.hasPrefix("第四十回") { return 40 }
        if title.hasPrefix("第四十一回") { return 41 }
        if title.hasPrefix("第四十二回") { return 42 }
        if title.hasPrefix("第四十三回") { return 43 }
        if title.hasPrefix("第四十四回") { return 44 }
        if title.hasPrefix("第四十五回") { return 45 }
        if title.hasPrefix("第四十六回") { return 46 }
        if title.hasPrefix("第四十七回") { return 47 }
        if title.hasPrefix("第四十八回") { return 48 }
        if title.hasPrefix("第四十九回") { return 49 }
        
        // Handle 50-59
        if title.hasPrefix("第五十回") { return 50 }
        if title.hasPrefix("第五十一回") { return 51 }
        if title.hasPrefix("第五十二回") { return 52 }
        if title.hasPrefix("第五十三回") { return 53 }
        if title.hasPrefix("第五十四回") { return 54 }
        if title.hasPrefix("第五十五回") { return 55 }
        if title.hasPrefix("第五十六回") { return 56 }
        if title.hasPrefix("第五十七回") { return 57 }
        if title.hasPrefix("第五十八回") { return 58 }
        if title.hasPrefix("第五十九回") { return 59 }
        
        // Handle 60
        if title.hasPrefix("第六十回") { return 60 }
        
        return 0 // fallback
    }
}