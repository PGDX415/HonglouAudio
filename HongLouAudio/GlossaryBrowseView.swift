//
//  GlossaryBrowseView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct GlossaryBrowseView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: GlossaryCategory? = nil
    @State private var selectedItem: GlossaryItem? = nil

    private let allItems = GlossaryStore.items

    private var filteredItems: [GlossaryItem] {
        var items = allItems
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            let keyword = searchText.lowercased()
            items = items.filter {
                $0.term.lowercased().contains(keyword) ||
                $0.pinyin.lowercased().contains(keyword) ||
                $0.explanation.lowercased().contains(keyword)
            }
        }
        return items
    }

    var body: some View {
        VStack(spacing: 0) {
            // Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryChip(
                        label: "全部",
                        isSelected: selectedCategory == nil,
                        color: theme.accentRed
                    ) {
                        selectedCategory = nil
                    }
                    ForEach(GlossaryCategory.allCases, id: \.self) { cat in
                        CategoryChip(
                            label: cat.rawValue,
                            isSelected: selectedCategory == cat,
                            color: categoryColor(cat)
                        ) {
                            selectedCategory = cat
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }

            // Items list
            List(filteredItems) { item in
                Button(action: { selectedItem = item }) {
                    glossaryRow(item)
                }
                .buttonStyle(PlainButtonStyle())
                .listRowBackground(theme.cardBackground)
            }
            .listStyle(PlainListStyle())
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .searchable(text: $searchText, prompt: "搜索词语或典故...")
        .navigationTitle("成语典故")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedItem) { item in
            glossaryDetailSheet(item)
        }
    }

    // MARK: - Row

    private func glossaryRow(_ item: GlossaryItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(categoryColor(item.category).opacity(0.1))
                    .frame(width: 36, height: 36)

                Image(systemName: categoryIcon(item.category))
                    .font(.system(size: 14))
                    .foregroundColor(categoryColor(item.category))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.term)
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundColor(theme.primaryText)

                    Text(item.pinyin)
                        .font(.system(size: 11))
                        .foregroundColor(theme.accentRed.opacity(0.7))
                }

                Text(item.explanation)
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(2)
                    .lineSpacing(3)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Detail Sheet

    private func glossaryDetailSheet(_ item: GlossaryItem) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(item.term)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(theme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(item.pinyin)
                        .font(.system(size: 15, design: .serif))
                        .foregroundColor(theme.accentRed)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(theme.accentRed.opacity(0.08))
                        .cornerRadius(8)

                    HStack(spacing: 4) {
                        Image(systemName: categoryIcon(item.category))
                            .font(.caption2)
                        Text(item.category.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(categoryColor(item.category))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(categoryColor(item.category).opacity(0.08))
                    .cornerRadius(8)

                    Divider().background(theme.divider)

                    Text(item.explanation)
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(theme.secondaryText)
                        .lineSpacing(7)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .presentationDetents([.medium, .large])
    }

    // MARK: - Helpers

    private func categoryColor(_ cat: GlossaryCategory) -> Color {
        switch cat {
        case .典故: return Color(red: 0.7, green: 0.3, blue: 0.3)
        case .词语: return Color(red: 0.3, green: 0.5, blue: 0.7)
        case .人物: return Color(red: 0.5, green: 0.3, blue: 0.6)
        case .器物: return Color(red: 0.6, green: 0.5, blue: 0.2)
        case .礼俗: return Color(red: 0.2, green: 0.5, blue: 0.5)
        case .地名: return Color(red: 0.3, green: 0.6, blue: 0.3)
        }
    }

    private func categoryIcon(_ cat: GlossaryCategory) -> String {
        switch cat {
        case .典故: return "book.fill"
        case .词语: return "character.textbox"
        case .人物: return "person.2.fill"
        case .器物: return "cup.and.saucer.fill"
        case .礼俗: return "hand.raised.fill"
        case .地名: return "mappin.circle.fill"
        }
    }
}

#Preview {
    NavigationStack {
        GlossaryBrowseView()
    }
}
