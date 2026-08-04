//
//  AchievementView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct AchievementView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var refreshID = UUID()
    @State private var selectedCategory: AchievementCategory? = nil

    private let achievements = AchievementStore.all
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var filteredAchievements: [AchievementDefinition] {
        if let cat = selectedCategory {
            return achievements.filter { $0.category == cat }
        }
        return achievements
    }

    private var unlockedCount: Int {
        achievements.filter { $0.isUnlocked() }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Summary header
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text("🏆")
                        .font(.title2)
                    Text("红楼成就")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(theme.primaryText)
                }

                Text("\(unlockedCount)/\(achievements.count) 已达成")
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(theme.accentRed)

                // Overall progress
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(theme.divider).frame(height: 4)
                        Capsule()
                            .fill(theme.accentRed)
                            .frame(width: geo.size.width * CGFloat(unlockedCount) / CGFloat(achievements.count), height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 40)
            }
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("全部", isSelected: selectedCategory == nil) {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedCategory = nil }
                    }

                    ForEach(AchievementCategory.allCases, id: \.self) { cat in
                        chip("\(cat.icon) \(cat.rawValue)", isSelected: selectedCategory == cat) {
                            withAnimation(.easeInOut(duration: 0.15)) { selectedCategory = cat }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)

            // Achievement grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredAchievements) { achievement in
                        achievementCard(achievement)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 20)
            }
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .navigationTitle("成就")
        .navigationBarTitleDisplayMode(.inline)
        .id(refreshID)
        .onAppear { refreshID = UUID() }
    }

    private func chip(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, design: .serif))
                .foregroundColor(isSelected ? .white : theme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? theme.accentRed : theme.cardBackground)
                )
                .overlay(
                    Capsule()
                        .stroke(theme.divider, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func achievementCard(_ achievement: AchievementDefinition) -> some View {
        let unlocked = achievement.isUnlocked()
        let prog = achievement.progress()

        return VStack(spacing: 6) {
            // Icon
            ZStack {
                Circle()
                    .fill(unlocked ? achievement.category.color.opacity(0.12) : theme.divider)
                    .frame(width: 46, height: 46)

                Image(systemName: achievement.icon)
                    .font(.system(size: 20))
                    .foregroundColor(unlocked ? achievement.category.color : theme.tertiaryText)
            }
            .padding(.top, 10)

            // Title
            Text(unlocked ? achievement.title : "???")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundColor(unlocked ? theme.primaryText : theme.tertiaryText)

            // Description
            Text(achievement.description)
                .font(.system(size: 11, design: .serif))
                .foregroundColor(theme.secondaryText.opacity(0.7))
                .multilineTextAlignment(.center)

            // Progress bar (only when in progress)
            if !unlocked {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(theme.divider).frame(height: 2)
                        if prog > 0 {
                            Capsule()
                                .fill(achievement.category.color)
                                .frame(width: geo.size.width * CGFloat(prog), height: 2)
                        }
                    }
                }
                .frame(height: 2)
                .padding(.horizontal, 20)

                Text(prog > 0 ? "\(Int(prog * 100))%" : "未开始")
                    .font(.system(size: 9))
                    .foregroundColor(prog > 0 ? achievement.category.color : theme.tertiaryText)
            }

            // Poem (only when unlocked)
            if unlocked {
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(theme.divider)
                        .frame(height: 0.5)
                        .padding(.horizontal, 8)

                    Text(achievement.poem)
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(theme.accentRed.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 6)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .frame(height: unlocked ? 210 : 170)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(unlocked ? achievement.category.color.opacity(0.2) : theme.divider, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        AchievementView()
    }
}
