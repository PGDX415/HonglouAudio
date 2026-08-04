//
//  RecipeView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct RecipeView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var selectedRecipe: Recipe? = nil
    @State private var searchText = ""

    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty { return RecipeStore.recipes }
        let keyword = searchText.lowercased()
        return RecipeStore.recipes.filter {
            $0.name.lowercased().contains(keyword) ||
            $0.context.lowercased().contains(keyword) ||
            $0.ingredients.joined().lowercased().contains(keyword)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    Text("红楼食谱")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(theme.deepRed)

                    Text("一粥一饭，尽显世家气象")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(theme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Recipe cards
                LazyVStack(spacing: 16) {
                    ForEach(filteredRecipes) { recipe in
                        recipeCard(recipe)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .searchable(text: $searchText, prompt: "搜索菜名、食材或回目...")
        .navigationTitle("")
        .navigationBarHidden(true)
        .sheet(item: $selectedRecipe) { recipe in
            recipeDetailSheet(recipe)
                .onAppear {
                    // Track unique recipes viewed for achievement
                    var viewed: Set<String> = []
                    if let data = UserDefaults.standard.data(forKey: "recipe_viewed_ids"),
                       let saved = try? JSONDecoder().decode(Set<String>.self, from: data) {
                        viewed = saved
                    }
                    viewed.insert(String(recipe.id))
                    UserDefaults.standard.set(viewed.count, forKey: "recipe_viewed_count")
                    if let data = try? JSONEncoder().encode(viewed) {
                        UserDefaults.standard.set(data, forKey: "recipe_viewed_ids")
                    }
                }
        }
    }

    // MARK: - Recipe Card

    private func recipeCard(_ recipe: Recipe) -> some View {
        Button(action: { selectedRecipe = recipe }) {
            VStack(alignment: .leading, spacing: 0) {
                // Color header bar
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        gradient: Gradient(colors: [recipe.color, recipe.color.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 80)

                    // Decorative chopsticks
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 3, height: 50)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 3, height: 55)
                    }
                    .padding(.leading, 18)
                    .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name)
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .shadow(radius: 2)

                        Text("第\(recipe.chapterNumber)回")
                            .font(.system(size: 11, design: .serif))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.leading, 56)
                    .padding(.bottom, 12)
                }

                // Context
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.context)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(theme.tertiaryText)
                        .lineLimit(2)
                        .padding(.bottom, 2)

                    Text(recipe.originalText)
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(theme.secondaryText)
                        .lineSpacing(5)
                        .lineLimit(4)

                    HStack {
                        Spacer()
                        Text("查看做法 →")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(recipe.color)
                    }
                    .padding(.top, 6)
                }
                .padding(14)
            }
            .background(theme.cardBackground)
            .cornerRadius(14)
            .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Detail Sheet

    private func recipeDetailSheet(_ recipe: Recipe) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero header
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            gradient: Gradient(colors: [recipe.color, recipe.color.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 130)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(recipe.name)
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .shadow(radius: 2)

                            HStack(spacing: 8) {
                                Image(systemName: "book.closed.fill")
                                    .font(.caption)
                                Text("第\(recipe.chapterNumber)回")
                                    .font(.system(size: 13, design: .serif))
                            }
                            .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.leading, 24)
                        .padding(.bottom, 16)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        // Context
                        VStack(alignment: .leading, spacing: 6) {
                            Text("书中场景")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(recipe.color)
                                .tracking(3)

                            Text(recipe.context)
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(theme.secondaryText)
                        }

                        Divider().background(theme.divider)

                        // Original text
                        VStack(alignment: .leading, spacing: 6) {
                            Text("原文引用")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(recipe.color)
                                .tracking(3)

                            Text(recipe.originalText)
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(theme.primaryText)
                                .lineSpacing(7)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Divider().background(theme.divider)

                        // Background
                        VStack(alignment: .leading, spacing: 6) {
                            Text("食话食说")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(recipe.color)
                                .tracking(3)

                            Text(recipe.description)
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(theme.secondaryText)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Divider().background(theme.divider)

                        // Ingredients
                        VStack(alignment: .leading, spacing: 8) {
                            Text("食材")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(recipe.color)
                                .tracking(3)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(recipe.ingredients, id: \.self) { ingredient in
                                    Text(ingredient)
                                        .font(.system(size: 12, design: .serif))
                                        .foregroundColor(theme.primaryText)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .frame(maxWidth: .infinity)
                                        .background(recipe.color.opacity(0.06))
                                        .cornerRadius(6)
                                }
                            }
                        }

                        Divider().background(theme.divider)

                        // Method
                        VStack(alignment: .leading, spacing: 8) {
                            Text("简略做法")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(recipe.color)
                                .tracking(3)

                            Text(recipe.method)
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(theme.secondaryText)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Divider().background(theme.divider)

                        // Fun fact
                        VStack(alignment: .leading, spacing: 6) {
                            Text("食趣")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(recipe.color)
                                .tracking(3)

                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.1))
                                    .padding(.top, 2)

                                Text(recipe.funFact)
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(theme.secondaryText)
                                    .lineSpacing(5)
                            }
                            .padding(12)
                            .background(Color(red: 0.8, green: 0.6, blue: 0.1).opacity(0.06))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    NavigationStack {
        RecipeView()
    }
}
