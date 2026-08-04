//
//  YaQuView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct YaQuView: View {
    @ObservedObject private var theme = ThemeManager.shared

    private let potteryGreen = Color(red: 0.2, green: 0.6, blue: 0.5)

    var body: some View {
        NavigationStack {
            List {
                // 诗词典藏
                Section {
                    NavigationLink(destination: PoetryView().navigationBarHidden(true)) {
                        HStack(spacing: 12) {
                            Image(systemName: "text.book.closed.fill")
                                .font(.title2)
                                .foregroundColor(theme.deepRed)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("诗词典藏")
                                    .font(.headline)
                                    .foregroundColor(theme.primaryText)
                                Text("一场繁华梦，满纸锦绣词")
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                // 红楼雅趣
                Section {
                    NavigationLink(destination: LanternRiddleView().navigationBarHidden(true)) {
                        yaQuRow(
                            icon: "lightbulb.max.fill",
                            color: Color(red: 0.85, green: 0.55, blue: 0.05),
                            title: "灯谜会",
                            subtitle: "制灯谜贾政悲谶语"
                        )
                    }

                    NavigationLink(destination: FlyingFlowerView().navigationBarHidden(true)) {
                        yaQuRow(
                            icon: "pencil.and.scribble",
                            color: potteryGreen,
                            title: "飞花令",
                            subtitle: "诗词接龙"
                        )
                    }

                    NavigationLink(destination: FlowerLotView().navigationBarHidden(true)) {
                        yaQuRow(
                            icon: "camera.macro",
                            color: Color(red: 0.8, green: 0.4, blue: 0.5),
                            title: "花名签",
                            subtitle: "寿怡红群芳开夜宴"
                        )
                    }

                    NavigationLink(destination: FortuneView().navigationBarHidden(true)) {
                        yaQuRow(
                            icon: "sparkles",
                            color: Color(red: 0.8, green: 0.6, blue: 0.2),
                            title: "求签问卜",
                            subtitle: "太虚幻境"
                        )
                    }

                    NavigationLink(destination: PersonalityQuizView()) {
                        yaQuRow(
                            icon: "theatermask.and.paintbrush.fill",
                            color: Color(red: 0.55, green: 0.4, blue: 0.65),
                            title: "我像红楼梦里的谁",
                            subtitle: "人格测试"
                        )
                    }

                    NavigationLink(destination: RecipeView()) {
                        yaQuRow(
                            icon: "fork.knife",
                            color: theme.accentRed,
                            title: "红楼食谱",
                            subtitle: "\(RecipeStore.recipes.count)道"
                        )
                    }

                    NavigationLink(destination: QuizView()) {
                        yaQuRow(
                            icon: "questionmark.circle.fill",
                            color: theme.accentRed,
                            title: "知识问答",
                            subtitle: "历史最佳：\(UserDefaults.standard.integer(forKey: "quiz_best_score"))/10"
                        )
                    }
                }

                // 成语典故
                Section {
                    NavigationLink(destination: GlossaryBrowseView()) {
                        yaQuRow(
                            icon: "character.book.closed.fill",
                            color: theme.accentRed,
                            title: "成语典故",
                            subtitle: "红楼文化辞典"
                        )
                    }
                }
            }
            .navigationTitle("雅趣")
            .listStyle(.grouped)
            .background(theme.pageBackground.ignoresSafeArea())
        }
    }

    private func yaQuRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)
            Text(title)
                .foregroundColor(theme.primaryText)
            Spacer()
            Text(subtitle)
                .font(.caption)
                .foregroundColor(theme.tertiaryText)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    YaQuView()
}
