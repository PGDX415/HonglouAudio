//
//  AchievementData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation
import SwiftUI

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String     // how to unlock
    let icon: String            // SF Symbol
    let poem: String            // 原著诗句，解锁后显示
    let category: AchievementCategory

    /// Returns progress 0...1 based on current app state
    func progress() -> Double {
        switch id {
        case "chapters_5":   return min(1, Double(ListeningStatsManager.shared.completedChapterCount) / 5)
        case "chapters_20":  return min(1, Double(ListeningStatsManager.shared.completedChapterCount) / 20)
        case "chapters_60":  return min(1, Double(ListeningStatsManager.shared.completedChapterCount) / 60)
        case "hours_10":     return min(1, ListeningStatsManager.shared.totalHours / 10)
        case "streak_7":     return min(1, Double(ListeningStatsManager.shared.currentStreak) / 7)
        case "streak_30":    return min(1, Double(ListeningStatsManager.shared.currentStreak) / 30)
        case "flyingFlower": return min(1, Double(UserDefaults.standard.integer(forKey: "flyingFlower_highScore")) / 100)
        case "quiz_perfect": return UserDefaults.standard.integer(forKey: "quiz_best_score") >= 10 ? 1 : 0
        case "lantern_all":  return min(1, Double(UserDefaults.standard.integer(forKey: "lanternRiddle_highScore")) / 90)
        case "flower_lot":   return min(1, Double(flowerUniqueCount()) / 12)
        case "fortune_10":   return min(1, Double(UserDefaults.standard.integer(forKey: "fortune_draw_count")) / 10)
        case "recipe_all":   return min(1, Double(recipeViewedCount()) / Double(RecipeStore.recipes.count))
        default: return 0
        }
    }

    func isUnlocked() -> Bool { progress() >= 1.0 }

    private func flowerUniqueCount() -> Int {
        guard let data = UserDefaults.standard.data(forKey: "flowerlot_collected") else { return 0 }
        return (try? JSONDecoder().decode(Set<String>.self, from: data))?.count ?? 0
    }

    private func recipeViewedCount() -> Int {
        UserDefaults.standard.integer(forKey: "recipe_viewed_count")
    }
}

enum AchievementCategory: String, CaseIterable {
    case listening = "听书"
    case streak = "恒心"
    case games = "雅戏"
    case explore = "探秘"

    var icon: String {
        switch self {
        case .listening: return "headphones"
        case .streak: return "flame"
        case .games: return "trophy"
        case .explore: return "map"
        }
    }

    var color: Color {
        switch self {
        case .listening: return Color(red: 0.55, green: 0.25, blue: 0.15)
        case .streak: return .orange
        case .games: return Color(red: 0.65, green: 0.4, blue: 0.1)
        case .explore: return Color(red: 0.2, green: 0.5, blue: 0.55)
        }
    }
}

struct AchievementStore {
    static let all: [AchievementDefinition] = [
        // 听书
        AchievementDefinition(
            id: "chapters_5", title: "初入大观园",
            description: "累计听完 5 回", icon: "door.left.hand.open",
            poem: "好生奇怪，倒像在那里见过一般",
            category: .listening
        ),
        AchievementDefinition(
            id: "chapters_20", title: "渐入佳境",
            description: "累计听完 20 回", icon: "building.columns",
            poem: "世事洞明皆学问，人情练达即文章",
            category: .listening
        ),
        AchievementDefinition(
            id: "chapters_60", title: "大梦初醒",
            description: "听完全部 60 回", icon: "moon.stars",
            poem: "落了片白茫茫大地真干净",
            category: .listening
        ),
        AchievementDefinition(
            id: "hours_10", title: "书海痴人",
            description: "累计收听 10 小时", icon: "clock.badge",
            poem: "都云作者痴，谁解其中味",
            category: .listening
        ),

        // 恒心
        AchievementDefinition(
            id: "streak_7", title: "七日不休",
            description: "连续收听 7 天", icon: "calendar.badge.clock",
            poem: "光阴荏苒须当惜，风雨阴晴任变迁",
            category: .streak
        ),
        AchievementDefinition(
            id: "streak_30", title: "三十日功",
            description: "连续收听 30 天", icon: "calendar.badge.checkmark",
            poem: "好风凭借力，送我上青云",
            category: .streak
        ),

        // 雅戏
        AchievementDefinition(
            id: "flyingFlower", title: "飞花魁首",
            description: "飞花令单局 ≥ 100 分", icon: "pencil.and.scribble",
            poem: "毫端蕴秀临霜写，口齿噙香对月吟",
            category: .games
        ),
        AchievementDefinition(
            id: "quiz_perfect", title: "满腹经纶",
            description: "知识问答满分 10/10", icon: "questionmark.circle",
            poem: "才华馥比仙，气质美如兰",
            category: .games
        ),
        AchievementDefinition(
            id: "lantern_all", title: "灯谜尽破",
            description: "灯谜会单局 ≥ 90 分", icon: "lightbulb.max",
            poem: "天上一轮才捧出，人间万姓仰头看",
            category: .games
        ),

        // 探秘
        AchievementDefinition(
            id: "flower_lot", title: "十二花神",
            description: "集齐全部 12 张花名签", icon: "camera.macro",
            poem: "千红一窟，万艳同杯",
            category: .explore
        ),
        AchievementDefinition(
            id: "fortune_10", title: "太虚行者",
            description: "求签问卜 10 次", icon: "sparkles",
            poem: "假作真时真亦假，无为有处有还无",
            category: .explore
        ),
        AchievementDefinition(
            id: "recipe_all", title: "红楼知味",
            description: "浏览全部红楼食谱", icon: "fork.knife",
            poem: "持螯更喜桂阴凉，泼醋擂姜兴欲狂",
            category: .explore
        ),
    ]
}
