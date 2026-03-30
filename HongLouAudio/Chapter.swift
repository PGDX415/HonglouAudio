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
    
    enum CodingKeys: String, CodingKey {
        case number = "number"
        case title = "title"
        case audioFileName = "audioFileName"
        case summary = "summary"
    }
}

struct ChaptersData: Codable {
    let chapters: [Chapter]
}