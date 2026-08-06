//
//  Chapter.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/30.
//

import Foundation

struct Chapter: Codable, Identifiable, Equatable, Hashable {
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        lhs.number == rhs.number && lhs.audioFileName == rhs.audioFileName
    }
    let id = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let number: Int
    let title: String
    let audioFileName: String
    let summary: String
    let textFileName: String?
    let paragraphTimestamps: [Double]?
    let season: Int

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
        case paragraphTimestamps = "paragraphTimestamps"
        case season = "season"
    }
}

struct ChaptersData: Codable {
    let chapters: [Chapter]
}

struct GroupedChapter: Identifiable, Hashable {
    let id = UUID()
    let chapterNumber: Int // The actual 回 number (1-60)
    let titlePrefix: String // e.g., "第一回 甄士隐梦幻识通灵 贾雨村风尘怀闺秀"
    let parts: [Chapter] // The individual parts (上, 中, 下)

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: GroupedChapter, rhs: GroupedChapter) -> Bool {
        lhs.id == rhs.id
    }
    
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
        // Extract the substring between "第" and "回", then parse as Chinese numerals.
        guard let huiStart = title.firstIndex(of: "第"),
              let huiEnd = title[huiStart...].firstIndex(of: "回") else {
            return 0
        }
        let numeral = String(title[title.index(after: huiStart)..<huiEnd])
        return parseChineseNumeral(numeral)
    }

    /// Parse Chinese numeral string (e.g. "六十一", "一百", "一零一", "一一零") to Int.
    private func parseChineseNumeral(_ s: String) -> Int {
        let digits: [Swift.Character: Int] = ["一":1,"二":2,"三":3,"四":4,"五":5,"六":6,"七":7,"八":8,"九":9,"零":0]

        // Try Arabic numerals first (e.g. "113")
        if let n = Int(s) { return n }

        // All-digit positional format: each char is a decimal place (e.g. "一一零"=110, "一二零"=120)
        let allDigits = s.allSatisfy { digits[$0] != nil }
        if allDigits {
            var result = 0
            for ch in s { result = result * 10 + digits[ch]! }
            return result
        }

        var result = 0
        var current = 0
        var hasHundred = false

        for ch in s {
            if let d = digits[ch] {
                current = d
            } else if ch == "百" {
                result += (current == 0 ? 1 : current) * 100
                current = 0
                hasHundred = true
            } else if ch == "十" {
                if hasHundred {
                    // After 百: "一百一十" → 十 means *10 for current digit
                    current = (current == 0 ? 1 : current) * 10
                } else {
                    result += (current == 0 ? 1 : current) * 10
                    current = 0
                }
            }
        }
        result += current
        return result
    }
}

// MARK: - Season Model

// MARK: - Part (部)

struct Part: Identifiable, Equatable {
    let id: Int               // 1 = 上部, 2 = 下部
    let name: String           // e.g., "上部·繁华如梦"
    let emoji: String          // 🏮 / ❄️
    let seasonIDs: [Int]       // contained season ids

    var shortName: String { name }

    static let upper = Part(
        id: 1, name: "上部·繁华如梦", emoji: "🏮",
        seasonIDs: [1, 2, 3, 4]
    )
    static let lower = Part(
        id: 2, name: "下部·繁华落尽", emoji: "❄️",
        seasonIDs: [5, 6, 7, 8]
    )

    static let allParts = [upper, lower]
}

// MARK: - Season Model

struct Season: Identifiable, Equatable {
    let id: Int
    let part: Int                    // 1 = 上部, 2 = 下部
    let name: String                 // e.g., "第一季·入府初识"
    let subtitle: String             // e.g., "🏯 繁华入梦"
    let theme: String                // e.g., "繁华入梦"
    let chapterRange: ClosedRange<Int>
    let description: String
    let introText: String
    let keyEvents: [String]
    let coverEmoji: String

    var displayTitle: String {
        "\(name)（第\(chapterRange.lowerBound)-\(chapterRange.upperBound)回）"
    }

    var shortTitle: String { name }

    /// All seasons in a given part
    static func seasons(for partID: Int) -> [Season] {
        allSeasons.filter { $0.part == partID }
    }

    static let allSeasons: [Season] = [
        // ── 上部·繁华如梦 ──
        Season(id: 1, part: 1,
            name: "第一季·入府初识", subtitle: "🏯 繁华入梦", theme: "繁华入梦",
            chapterRange: 1...15,
            description: "黛玉进府、宝钗到来、秦可卿之死、凤姐理家",
            introText: "繁华掩映下的贾府，一梦初醒。黛玉孤身入京，步步留心时时在意；宝钗携金锁而至，金玉良缘初现端倪。秦可卿香消玉殒，凤姐初展治家手腕。一切故事，从此开始。",
            keyEvents: ["黛玉进府","宝钗到来","梦游太虚","刘姥姥一进荣国府","秦可卿之死","凤姐协理宁国府"],
            coverEmoji: "🏯"),
        Season(id: 2, part: 1,
            name: "第二季·大观园盛景", subtitle: "🌸 园中春秋", theme: "园中春秋",
            chapterRange: 16...30,
            description: "元妃省亲、宝黛读西厢、黛玉葬花",
            introText: "元妃省亲，大观园中群芳毕集，极尽人间富贵。宝黛共读西厢，情愫暗生；黛玉葬花吟诗，字字泣血。青春的欢愉与哀愁在园中交织，奏出最美的乐章。",
            keyEvents: ["元妃省亲","宝黛读西厢","黛玉葬花","宝钗扑蝶","蒋玉菡赠茜香罗","清虚观打醮"],
            coverEmoji: "🌸"),
        Season(id: 3, part: 1,
            name: "第三季·群芳争艳", subtitle: "🎭 悲喜交加", theme: "悲喜交加",
            chapterRange: 31...45,
            description: "宝玉挨打、海棠诗社、刘姥姥游园、凤姐泼醋",
            introText: "宝玉挨打震动全府，海棠诗社雅集群芳。刘姥姥游园引得笑声满堂，凤姐泼醋大闹寿宴。宝钗兰言解疑癖，黛玉风雨制秋词。悲喜交错之间，人心悄然变化。",
            keyEvents: ["宝玉挨打","海棠诗社","菊花诗会","刘姥姥游大观园","凤姐泼醋","钗黛金兰契"],
            coverEmoji: "🎭"),
        Season(id: 4, part: 1,
            name: "第四季·暗流涌动", subtitle: "🌑 繁华将尽", theme: "繁华将尽",
            chapterRange: 46...60,
            description: "鸳鸯抗婚、探春理家、紫鹃试玉、内部矛盾激化",
            introText: "繁华之下暗流涌动。鸳鸯剪发明志，探春兴利除弊，紫鹃情辞试出宝玉真心。芦雪庵联诗尚有余温，玫瑰露风波已见裂痕。盛世的帷幕将落，无人知晓。",
            keyEvents: ["鸳鸯抗婚","香菱学诗","芦雪庵联诗","探春理家","紫鹃试玉","玫瑰露风波"],
            coverEmoji: "🌑"),

        // ── 下部·繁华落尽 ──
        Season(id: 5, part: 2,
            name: "第五季·风雨欲来", subtitle: "🍂 祸起萧墙", theme: "祸起萧墙",
            chapterRange: 61...75,
            description: "尤二姐吞金、抄检大观园前夕、桃花社重建",
            introText: "尤二姐吞金自尽，凤姐大闹宁国府。桃花社虽重建，诗情难掩暗流。抄检大观园的前夜，人心惶惶，大厦将倾的先兆已悄然显现。",
            keyEvents: ["尤二姐吞金","凤姐大闹宁国府","桃花社重建","贾母八旬大庆","抄检大观园前夕"],
            coverEmoji: "🍂"),
        Season(id: 6, part: 2,
            name: "第六季·群芳凋零", subtitle: "🥀 芳魂消散", theme: "芳魂消散",
            chapterRange: 76...90,
            description: "抄检大观园、晴雯之死、迎春出嫁、黛玉绝粒",
            introText: "抄检大观园，晴雯抱屈夭亡。迎春误嫁中山狼，香菱屈受贪夫棒。黛玉病中绝粒，芳魂渐远。曾经繁花似锦的大观园，已是秋风扫落叶。",
            keyEvents: ["抄检大观园","晴雯之死","迎春出嫁","香菱受虐","黛玉绝粒","宝玉失玉"],
            coverEmoji: "🥀"),
        Season(id: 7, part: 2,
            name: "第七季·大厦将倾", subtitle: "🏚️ 香消玉殒", theme: "香消玉殒",
            chapterRange: 91...105,
            description: "元妃薨逝、黛玉焚稿、宝钗出闺、贾府被抄",
            introText: "元妃薨逝，宝玉疯癫。黛玉焚稿断痴情，宝钗出闺成大礼。锦衣军查抄宁国府，百年望族一朝倾覆。潇湘馆内，绛珠仙子魂归离恨天。",
            keyEvents: ["元妃薨逝","黛玉焚稿","宝钗出闺","贾府被抄","贾母祷天"],
            coverEmoji: "🏚️"),
        Season(id: 8, part: 2,
            name: "第八季·白茫茫大地", subtitle: "❄️ 大地真干净", theme: "大地真干净",
            chapterRange: 106...120,
            description: "贾母寿终、凤姐病逝、鸳鸯殉主、宝玉出家",
            introText: "贾母寿终归地府，凤姐力诎失人心。鸳鸯殉主，妙玉遭劫，惜春出家。宝玉中举后了却尘缘，白茫茫大地真干净。好一似食尽鸟投林，落了片白茫茫大地真干净。",
            keyEvents: ["贾母寿终","凤姐病逝","鸳鸯殉主","妙玉遭劫","惜春出家","宝玉出家"],
            coverEmoji: "❄️")
    ]

    /// Returns the season that contains a given 回 number, or nil
    static func season(for chapterNumber: Int) -> Season? {
        allSeasons.first { $0.chapterRange.contains(chapterNumber) }
    }
}